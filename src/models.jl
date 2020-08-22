export FitInput
export SimulateInput
export FitResult

"""
FitInput(parameters::Dict{String,Any}, 
            dependent::Vector{TimeSeries{T}},
            exogenous::Vector{TimeSeries{T}}) where T

FitInput is the only information needed by Fit Functions
Fit Functions will just use dependent, exogenous and parameters
All extra information passed to the Fit Function that is not the dataset must be inside the parameters Dict.
You can also include keys 'args' ands 'kwargs' inside the dictionary and they will be passed directly to the FitFunction
"""
mutable struct FitInput{T}
    parameters::Dict{String,Any}
    dependent::Vector{TimeSeries{T}}
    exogenous::Vector{TimeSeries{T}}

    function FitInput(parameters::Dict{String,Any}, 
                           dependent::Vector{TimeSeries{T}},
                           exogenous::Vector{TimeSeries{T}}) where T
        # Test if the dependent vector is empty.
        if isempty(dependent)
            throw(ErrorException("Must have at least one dependent time series."))
        end
        # Warn if the exogenous vector is empty.
        has_exogenous_variable = !isempty(exogenous)
        if !has_exogenous_variable
            @warn("Deterministic has no exogenous variables.")
        end
        # Test if all the dependent have the same timestamps
        if !assert_vector_time_series_timestamps(dependent)
            throw(DimensionMismatch("dependent timestamps must be the same."))
        end
        # Test if all the exogenous have the same timestamps
        if has_exogenous_variable && (!assert_vector_time_series_timestamps(exogenous))
            throw(DimensionMismatch("exogenous timestamps must be the same."))
        end
        # Test if dependent and exogenous have the same timestaamps
        if has_exogenous_variable && (!assert_two_vectors_time_series_timestamps(dependent[1], exogenous[1]))
            throw(DimensionMismatch("exogenous and dependent timestamps must be the same."))
        end

        return new{T}(parameters, 
                    dependent,
                    exogenous)
    end
end

"""
FitResult(hyperparameters,
            other)

May be developed specifically for each model.
Ideally all the essential information that flows from fit to simulate should be in the hyperparameters.
"""
mutable struct FitResult
    hyperparameters
    other

    function FitResult(hyperparameters,
                        other)
        return new(hyperparameters, other)
    end
end

# Additional constructor for FitResult
function FitResult(hyperparameters)
    return FitResult(hyperparameters, nothing)
end

"""
SimulateInput(fit_input::FitInput{T}
                timestamps_forecast::Vector{DateTime}
                exogenous_forecast::Vector{TimeSeries{T}}
                fit_result::FitResult)

SimulateInput is the only information needed by Simulate Functions
FitResult may be developed specifically for each FitFunction or you can use the generic version.
Ideally all the essential information that flows from fit to simulate should be in the hyperparameters.
"""
mutable struct SimulateInput{T}
    fit_input::FitInput{T}
    timestamps_forecast::Vector{DateTime}
    exogenous_forecast::Vector{TimeSeries{T}}
    fit_result::FitResult

    function SimulateInput(fit_input::FitInput{T},
                            timestamps_forecast::Vector{DateTime},
                            exogenous_forecast::Vector{TimeSeries{T}},
                            fit_result::FitResult) where T
        
        # Having parameters, dependent and exogenous here makes possible to perform all the tests
        parameters = fit_input.parameters
        dependent = fit_input.dependent
        exogenous = fit_input.exogenous
        has_exogenous_variable = !isempty(exogenous)

        # Test if exogenous and exogenous_forecast have the same number of time series
        if !(length(exogenous) == length(exogenous_forecast))
            throw(ErrorException("exogenous and exogenous_forecast must have the same numbers of time_series."))
        end

        # Test if all the exogenous_forecast have the same timestamps
        if has_exogenous_variable && (!assert_vector_time_series_timestamps(exogenous_forecast))
            throw(DimensionMismatch("exogenous_forecast timestamps must be the same."))
        end
        # Warn if exogenous_forecast timestamps are not greater than dependent timestamps
        if has_exogenous_variable && (dependent[1].timestamps[end] >= exogenous_forecast[1].timestamps[1])
            @warn("timestamps of exogenous forecast are not greater than dependent timestamps.")
        end
        # Test if each exogenous_forecast timestamps is equal timestamps_forecast
        if has_exogenous_variable && (!all([isequal(timestamps_forecast, exogenous_forecast[i].timestamps) for i = 1:length(exogenous_forecast)]))
            throw(DimensionMismatch("timestamps_forecast must be equal to each exogenous_forecast.timestamps"))
        end
        return new{T}(fit_input, 
                    timestamps_forecast,
                    exogenous_forecast,
                    fit_result,)
    end
end

# Assert Functions
function assert_vector_time_series_timestamps(vector_ts::Vector{TimeSeries{T}}) where T
    reference = vector_ts[1].timestamps
    for ts in vector_ts
        if !(isequal(ts.timestamps, reference))
            return false
        end
    end
    return true
end

function assert_two_vectors_time_series_timestamps(reference_ts::TimeSeries{T}, 
                                                   comparision_ts::TimeSeries{T}) where T
    return isequal(reference_ts.timestamps, comparision_ts.timestamps)
end

function assert_length_time_series_timestamp(ts::TimeSeries{T}, len_timestamps::Int) where T
    return isequal(ts.timestamps, len_timestamps)
end
