export PointForecast, 
    ScenariosForecast, 
    QuantilesForecast

export PointForecastMetrics,
    ScenariosForecastMetrics

export forecast_metrics

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

    function PointForecast(name::String,
                           timestamps::Vector{DateTime},
                           forecast::Vector{T}) where T <: Real

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
function PointForecast(name::String,
                       timestamps::Vector{Date},
                       forecast::Vector{T}) where T <: Real
    
    return PointForecast(name, 
                         DateTime.(timestamps),
                         forecast)
end

## Evaluation Metrics for Point Forecast
struct PointForecastMetrics{T <: Real}
    me::Vector{T}
    mae::Vector{T}
    mape::Vector{T}
end

function forecast_metrics(point_forecast::PointForecast{T}, 
                          real_ts::TimeSeries{T}) where T

    if length(point_forecast.forecast) != length(real_ts.vals)
        throw(DimensionMismatch("real values and forecast do not have the same length."))
    end
    me   = mean_error(real_ts.vals, point_forecast.forecast)
    mae  = mean_absolute_error(real_ts.vals, point_forecast.forecast)

    if observations_close_to_zero(real_ts)
        @warn("The real observations have values too close to zero. This makes the MAPE " *
              "impractical, a vector of NaNs will be returned.")
        mape = NaN .* zeros(length(real_ts.timestamps))
    else
        mape = mean_absolute_percentage_error(real_ts.vals, point_forecast.forecast)
    end
    return PointForecastMetrics{T}(me, mae, mape)
end

error(real::Vector{T}, forecast::Vector{T}) where T = real .- forecast
absolute_error(real::Vector{T}, forecast::Vector{T}) where T = abs.(error(real, forecast))
absolute_percentage_error(real::Vector{T}, forecast::Vector{T}) where T = abs.(error(real, forecast)./real)

function mean_error(real::Vector{T}, forecast::Vector{T}) where T
    mean_err = Vector{T}(undef, length(real))
    err = error(real, forecast)
    for i in eachindex(real)
        mean_err[i] = mean(err[1:i])
    end
    return mean_err
end

function mean_absolute_error(real::Vector{T}, forecast::Vector{T}) where T
    mean_absolute_err = Vector{T}(undef, length(real))
    abs_err = absolute_error(real, forecast)
    for i in eachindex(real)
        mean_absolute_err[i] = mean(abs_err[1:i])
    end
    return mean_absolute_err
end

function mean_absolute_percentage_error(real::Vector{T}, forecast::Vector{T}) where T
    mean_absolute_percentage_err = Vector{T}(undef, length(real))
    abs_percentage_err = absolute_percentage_error(real, forecast)
    for i in eachindex(real)
        mean_absolute_percentage_err[i] = mean(abs_percentage_err[1:i])
    end
    return mean_absolute_percentage_err
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

    function ScenariosForecast(name::String,
                               timestamps::Vector{DateTime},
                               scenarios::Matrix{T},
                               quantiles_probabilities::Vector{T},
                               quantiles::Matrix{T}) where T <: Real

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
function ScenariosForecast(name::String,
                           timestamps::Vector{Date},
                           scenarios::Matrix{T},
                           quantiles_probabilities::Vector{T},
                           quantiles::Matrix{T}) where T <: Real

    return ScenariosForecast(name, 
                             DateTime.(timestamps),
                             scenarios,
                             quantiles_probabilities,
                             quantiles)
end

## Evaluation Metrics for Point Forecast
struct ScenariosForecastMetrics{T <: Real}
    probabilistic_calibration::Dict{Float64, Float64}
end

function forecast_metrics(scenarios_forecast::ScenariosForecast{T}, 
                          real_ts::TimeSeries{T}) where T

    if size(scenarios_forecast.scenarios, 1) != length(real_ts.vals)
        throw(DimensionMismatch("real values and forecast do not have the same length."))
    end

    probabilistic_calibration = evaluate_probabilistic_calibration(scenarios_forecast.scenarios, real_ts.vals)
    return ScenariosForecastMetrics{T}(
        probabilistic_calibration
    )
end

function number_of_hits(quantile::Vector{T},
                        vals::Vector{T}) where T
    num_hits = 0
    for i in 1:length(vals)
        if vals[i] <= quantile[i]
            num_hits += 1
        end
    end
    return num_hits
end
function percentage_of_hits(quantile::Vector{T},
                            vals::Vector{T}) where T
    return number_of_hits(quantile, vals) / length(vals)
end

function get_quantiles(quantile_probs::Vector{T}, scenarios::Matrix{T}) where T
    quantiles = mapslices(x -> quantile(x, quantile_probs), scenarios; dims = 2)
    return quantiles
end

function evaluate_probabilistic_calibration(scenarios::Matrix{T},
                                         vals::Vector{T}) where T
    quantile_probs = collect(0.025:0.05:0.975)
    quantiles = get_quantiles(quantile_probs, scenarios)
    probabilistic_calibration = Dict{Float64, Float64}()
    for (i, q) in enumerate(quantile_probs)
        probabilistic_calibration[q] = percentage_of_hits(quantiles[:, i], vals)
    end
    return probabilistic_calibration
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

    function QuantilesForecast(name::String,
                               timestamps::Vector{DateTime},
                               quantiles_probabilities::Vector{T},
                               quantiles::Matrix{T}) where T <: Real
 
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
function QuantilesForecast(name::String,
                           timestamps::Vector{Date},
                           quantiles_probabilities::Vector{T},
                           quantiles::Matrix{T}) where T <: Real

    return QuantilesForecast(name,
                             DateTime.(timestamps),
                             quantiles_probabilities,
                             quantiles)
end