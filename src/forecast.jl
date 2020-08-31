export PointForecast, ScenariosForecast, QuantilesForecast

export PointForecastMetrics, ScenariosForecastMetrics

export forecast_metrics
export cross_validation

abstract type Forecast end
abstract type ProbabilisticForecast <: Forecast end

"""
    PointForecast

Define the results of point forecasts.    
"""
mutable struct PointForecast{T <: Real} <: Forecast
    name::String
    timestamps::Vector{DateTime}
    forecast::Vector{T}

    function PointForecast(
        name::String,
        timestamps::Vector{DateTime},
        forecast::Vector{T},
    ) where {T <: Real}

        if length(timestamps) != length(forecast)
            throw(DimensionMismatch("timestamps and forecast do not have the same length."))
        end

        if !allunique(timestamps)
            throw(ErrorException("timestamps must be unique."))
        end

        if !issorted(timestamps)
            throw(ErrorException("timestamps must be sorted."))
        end

        return new{T}(name, timestamps, forecast)
    end
end

# Additional constructors
function PointForecast(
    name::String,
    timestamps::Vector{Date},
    forecast::Vector{T},
) where {T <: Real}

    return PointForecast(name, DateTime.(timestamps), forecast)
end

## Evaluation Metrics for Point Forecast
struct PointForecastMetrics{T <: Real}
    errors::Vector{T}
    absolute_percentage_errors::Vector{T}
end

function forecast_metrics(
    point_forecast::PointForecast{T},
    real_ts::TimeSeries{T},
) where {T}

    if length(point_forecast.forecast) != length(real_ts.vals)
        throw(DimensionMismatch("real values and forecast do not have the same length."))
    end

    err = error(real_ts.vals, point_forecast.forecast)
    if observations_close_to_zero(real_ts)
        @warn(
            "The real observations have values too close to zero. This makes the " *
            "absolute percentage error impractical, NaNs will be returned."
        )
        abs_percentage_err = [NaN]
    else
        abs_percentage_err =
            absolute_percentage_error(real_ts.vals, point_forecast.forecast)
    end
    return PointForecastMetrics{T}(err, abs_percentage_err)
end

error(real::Vector{T}, forecast::Vector{T}) where {T} = real .- forecast
absolute_percentage_error(real::Vector{T}, forecast::Vector{T}) where {T} =
    abs.(error(real, forecast) ./ real)

"""
    cross_validation(fit_input::FitInput{T}, fit_function::Function, predict_function::Function, metric_function::Function,
                            min_history::Int, horizon::Int)

Function that receives all avaiable data in fit_input, a fit_function and a prediction_funtion,
a validation metric (eg. mape), a min_history as a starting point and a prediction horizon.
Returns the result of the cross validation separeted by lead time.
"""
function cross_validation(fit_input::FitInput{T},
                            fit_function::Function, 
                            predict_function::Function,
                            metric_function::Function,
                            min_history::Int, 
                            horizon::Int) where T
    n = length(fit_input.dependent[1].timestamps)
    metric_matrix = Matrix{Float64}(undef, length(min_history:(n - horizon)), horizon)
    for i = min_history:(n - horizon)
        training_dependent = map(x -> TimeSeries(x.name, x.timestamps[1:i], x.vals[1:i]), fit_input.dependent)
        training_exogenous = map(x -> TimeSeries(x.name, x.timestamps[1:i], x.vals[1:i]), fit_input.exogenous)
        training_fit_input = FitInput(fit_input.parameters, training_dependent, training_exogenous)
        validation_fit_result = fit_function(training_fit_input)
        validation_timestamps_forecast = fit_input.dependent[1].timestamps[(i + 1):(i + horizon)]
        validation_exogenous_forecast = map(x -> TimeSeries(x.name, x.timestamps[(i + 1):(i + horizon)], x.vals[(i + 1):(i + horizon)]), fit_input.exogenous)
        validation_simulate_input = SimulateInput(training_fit_input, validation_timestamps_forecast,
                                                    validation_exogenous_forecast, validation_fit_result)
        point_forecast = predict_function(validation_simulate_input)
        observed = map(x -> TimeSeries(x.name, x.timestamps[(i + 1):(i + horizon)], x.vals[(i + 1):(i + horizon)]), fit_input.dependent)
        metric_matrix[(i - min_history + 1), :] .= metric_function(observed[1].vals, point_forecast.forecast)
    end
    return mean(metric_matrix, dims=1)
end

"""
    ScenariosForecast

Define the probabilistic forecast results calculated from scenarios.   
"""
mutable struct ScenariosForecast{T <: Real} <: ProbabilisticForecast
    name::String
    timestamps::Vector{DateTime}
    scenarios::Matrix{T}
    quantiles_probabilities::Vector{T}
    quantiles::Matrix{T}

    function ScenariosForecast(
        name::String,
        timestamps::Vector{DateTime},
        scenarios::Matrix{T},
        quantiles_probabilities::Vector{T},
        quantiles::Matrix{T},
    ) where {T <: Real}

        if length(timestamps) != size(scenarios, 1)
            throw(DimensionMismatch("timestamps and scenarios do not have the same length."))
        end

        if length(timestamps) != size(quantiles, 1)
            throw(DimensionMismatch("timestamps and quantiles do not have the same length."))
        end

        if length(quantiles_probabilities) != size(quantiles, 2)
            throw(DimensionMismatch("quantiles_probabilities and quantiles do not have the same length."))
        end

        if !allunique(timestamps)
            throw(ErrorException("timestamps must be unique."))
        end

        if !issorted(timestamps)
            throw(ErrorException("timestamps must be sorted."))
        end

        return new{T}(name, timestamps, scenarios, quantiles_probabilities, quantiles)
    end
end

# Additional constructors
function ScenariosForecast(
    name::String,
    timestamps::Vector{Date},
    scenarios::Matrix{T},
    quantiles_probabilities::Vector{T},
    quantiles::Matrix{T},
) where {T <: Real}

    return ScenariosForecast(
        name,
        DateTime.(timestamps),
        scenarios,
        quantiles_probabilities,
        quantiles,
    )
end

## Evaluation Metrics for Point Forecast
struct ScenariosForecastMetrics
    # A Vector of dictionaaries for each lead time 
    # where each key is a quantile and each value 
    # is wheather the observation is smaller than 
    # the quantile.
    probabilistic_calibration::Vector{Dict{Float64,Bool}}
    # A Vector of dictionaaries for each lead time
    # where each key is the confidence interval
    # and each value is the width of the interval in the 
    # unit of the dependent variable.
    interval_width::Vector{Dict{Float64,Float64}}
    # A Vector that contains the crps score for each 
    # lead time 
    crps::Vector{Float64}
end

function forecast_metrics(
    scenarios_forecast::ScenariosForecast,
    real_ts::TimeSeries{T},
) where {T}

    if size(scenarios_forecast.scenarios, 1) != length(real_ts.vals)
        throw(DimensionMismatch("real values and forecast do not have the same length."))
    end

    probabilistic_calibration =
        evaluate_probabilistic_calibration(scenarios_forecast.scenarios, real_ts.vals)
    interval_width = evaluate_interval_width(scenarios_forecast.scenarios)
    crps = evaluate_crps(scenarios_forecast.scenarios, real_ts.vals)

    return ScenariosForecastMetrics(probabilistic_calibration, interval_width, crps)
end

function get_quantiles(quantile_probs::Vector{T}, scenarios::Matrix{T}) where {T}
    quantiles = mapslices(x -> quantile(x, quantile_probs), scenarios; dims=2)
    return quantiles
end

## probabilistic_calibration functions
hitted_below_quantile(val::T, quantile::T) where {T} = val <= quantile

function evaluate_probabilistic_calibration(scenarios::Matrix{T}, vals::Vector{T}) where {T}
    quantile_probs = collect(0.025:0.05:0.975)
    quantiles = get_quantiles(quantile_probs, scenarios)
    probabilistic_calibration = Vector{Dict}(undef, size(scenarios, 1))
    for k = 1:size(scenarios, 1)
        probabilistic_calibration[k] = Dict{Float64,Bool}()
        for (i, q) in enumerate(quantile_probs)
            probabilistic_calibration[k][q] =
                hitted_below_quantile(vals[k], quantiles[k, i])
        end
    end
    return probabilistic_calibration
end

lower_quantile(interval_prob::T) where {T} = (1 - interval_prob) / 2
upper_quantile(interval_prob::T) where {T} = (1 + interval_prob) / 2

width_of_interval(upper_quantile::T, lower_quantile::T) where {T} =
    upper_quantile - lower_quantile

function evaluate_interval_width(scenarios::Matrix{T}) where {T}
    intervals_probs = collect(0.05:0.05:0.95)
    interval_width = Vector{Dict}(undef, size(scenarios, 1))
    upper_quantiles = get_quantiles(upper_quantile.(intervals_probs), scenarios)
    lower_quantiles = get_quantiles(lower_quantile.(intervals_probs), scenarios)
    for k = 1:size(scenarios, 1)
        interval_width[k] = Dict{Float64,Float64}()
        for (i, q) in enumerate(intervals_probs)
            interval_width[k][q] =
                width_of_interval(upper_quantiles[k, i], lower_quantiles[k, i])
        end
    end
    return interval_width
end

# crps functions
discrete_crps_indicator_function(val::T, z::T) where {T} = val < z

function crps(scenarios::Vector{T}, val::T) where {T}
    sorted_scenarios = sort(scenarios)
    m = length(scenarios)
    crps_score = zero(T)

    for i = 1:m
        crps_score +=
            (sorted_scenarios[i] - val) *
            (m * discrete_crps_indicator_function(val, sorted_scenarios[i]) - i + 0.5)
    end

    return (2 / m^2) * crps_score
end

function evaluate_crps(scenarios::Matrix{T}, vals::Vector{T}) where {T}
    crps_scores = Vector{Float64}(undef, length(vals))

    for k = 1:length(vals)
        crps_scores[k] = crps(scenarios[k, :], vals[k])
    end

    return crps_scores
end


function mean_of_metrics(forecast::Vector{ScenariosForecastMetrics})
    # TODO assert all forecast metrics have the same length.
    mean_of_probabilistic_calibration = mean_probabilistic_calibration(forecast)
    mean_of_interval_width = mean_interval_width(forecast)
    mean_of_crps = mean_crps(forecast)
    return mean_of_probabilistic_calibration, mean_of_interval_width, mean_of_crps
end

function mean_probabilistic_calibration(forecast::Vector{ScenariosForecastMetrics})
    m_probabilistic_calibrations =
        Vector{Dict{Float64,Float64}}(undef, length(forecast[1].probabilistic_calibration))
    for t = 1:length(m_probabilistic_calibrations)
        for forec in forecast
            m_probabilistic_calibrations[t] = Dict{Float64,Float64}()
            for (k, v) in forec.probabilistic_calibration[t]
                if !haskey(m_probabilistic_calibrations[t], k)
                    m_probabilistic_calibrations[t][k] = v / length(forecast)
                else
                    m_probabilistic_calibrations[t][k] += v / length(forecast)
                end
            end
        end
    end
    return m_probabilistic_calibrations
end

function mean_interval_width(forecast::Vector{ScenariosForecastMetrics})
    m_interval_width =
        Vector{Dict{Float64,Float64}}(undef, length(forecast[1].interval_width))
    for t = 1:length(m_interval_width)
        for forec in forecast
            m_interval_width[t] = Dict{Float64,Float64}()
            for (k, v) in forec.interval_width[t]
                if !haskey(m_interval_width[t], k)
                    m_interval_width[t][k] = v / length(forecast)
                else
                    m_interval_width[t][k] += v / length(forecast)
                end
            end
        end
    end
    return m_interval_width
end

function mean_crps(forecast::Vector{ScenariosForecastMetrics})
    m_crps = Matrix{Float64}(undef, length(forecast[1].crps), length(forecast))
    for (i, forec) in enumerate(forecast)
        m_crps[:, i] = forec.crps
    end
    return vec(mean(m_crps, dims=2))
end


"""
    QuantilesForecast

Define the probabilistic forecast results calculated from distributions.      
"""
mutable struct QuantilesForecast{T <: Real} <: ProbabilisticForecast
    name::String
    timestamps::Vector{DateTime}
    quantiles_probabilities::Vector{T}
    quantiles::Matrix{T}

    function QuantilesForecast(
        name::String,
        timestamps::Vector{DateTime},
        quantiles_probabilities::Vector{T},
        quantiles::Matrix{T},
    ) where {T <: Real}

        if length(timestamps) != size(quantiles, 1)
            throw(DimensionMismatch("timestamps and quantiles do not have the same length."))
        end

        if length(quantiles_probabilities) != size(quantiles, 2)
            throw(DimensionMismatch("quantiles_probabilities and quantiles do not have the same length."))
        end

        if !allunique(timestamps)
            throw(ErrorException("timestamps must be unique."))
        end

        if !issorted(timestamps)
            throw(ErrorException("timestamps must be sorted."))
        end

        return new{T}(name, timestamps, quantiles_probabilities, quantiles)
    end
end

# Additional constructors
function QuantilesForecast(
    name::String,
    timestamps::Vector{Date},
    quantiles_probabilities::Vector{T},
    quantiles::Matrix{T},
) where {T <: Real}

    return QuantilesForecast(
        name,
        DateTime.(timestamps),
        quantiles_probabilities,
        quantiles,
    )
end
