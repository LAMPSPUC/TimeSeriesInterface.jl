export ModelInput
export FitResult

"""
Must be developed for each model.
This is a basic struct that can be used for quick modelling.
"""
mutable struct FitResult
    hyperparameters::Vector{Float64}
    other::Any

    function FitResult(hyperparameters::Vector{Float64},
                        other::Any)
        return new(hyperparameters, other)
    end
end

"""
Additional constructor for FitResult, requires only the hyperparameters.
"""
function FitResult(hyperparameters::Vector{Float64})
    return FitResult(hyperparameters, nothing)
end

"""
ModelInput is the only information needed by Fit Functions
Fit Functions will just use dependent, exogenous and parameters
All extra information passed to the Fit Function that is not the dataset must be inside the parameters Dict.
You can also include keys 'args' ands 'kwargs' inside the dictionary and they will be passed directly to the FitFunction
Simulate Functions need ModelInput and also a FitResult, developed specifically for each FitFunction
"""
mutable struct ModelInput{T}
    parameters::Dict{String,Any}
    dependent::Vector{TimeSeries{T}}
    exogenous::Vector{TimeSeries{T}}
    timestamps_forecast::Vector{DateTime}
    exogenous_forecast::Vector{TimeSeries{T}}

    function ModelInput(parameters::Dict{String,Any}, 
                           dependent::Vector{TimeSeries{T}},
                           exogenous::Vector{TimeSeries{T}},
                           timestamps_forecast::Vector{DateTime},
                           exogenous_forecast::Vector{TimeSeries{T}}) where T
        # Test if there is the key steps_ahead in parameters.
        # if !haskey(parameters, "steps_ahead")
        #     throw(ErrorException("Deterministic must have steps_ahead."))
        # end
        # Test if the dependent vector is empty.
        if isempty(dependent)
            throw(ErrorException("Must have at least one dependent time series."))
        end
        # Test if exogenous and exogenous_forecast have the same number of time series
        if !(length(exogenous) == length(exogenous_forecast))
            throw(ErrorException("exogenous and exogenous_forecast must have the same numbers of time_series."))
        end
        # Test if the exogenous vector is empty.
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
        # Test if all the exogenous_forecast have the same timestamps
        if has_exogenous_variable && (!assert_vector_time_series_timestamps(exogenous_forecast))
            throw(DimensionMismatch("exogenous_forecast timestamps must be the same."))
        end
        # Test if all the exogenous forecast timestamps has length equal to steps ahead
        # if has_exogenous_variable && !assert_length_time_series_timestamp(exogenous_forecast[1], parameters["steps_ahead"])
        #     throw(ErrorException("exogenous_forecast timestamps must have the same length as steps ahead."))
        # end
        # Test if dependent and exogenous have the same timestaamps
        if has_exogenous_variable && (!assert_two_vectors_time_series_timestamps(dependent[1], exogenous[1]))
            throw(DimensionMismatch("exogenous and dependent timestamps must be the same."))
        end
        # Test if exogenous_forecast timestamps are greater than dependent timestamps
        if has_exogenous_variable && (dependent[1].timestamps[end] >= exogenous_forecast[1].timestamps[1])
            throw(ErrorException("timestamps of exogenous forecast must be greater than" *
                                 " dependent timestamps."))
        end
        # Test if each exogenous_forecast timestamps is equal timestamps_forecast
        if has_exogenous_variable && (!all([isequal(timestamps_forecast, exogenous_forecast[i].timestamps) for i = 1:length(exogenous_forecast)]))
            throw(DimensionMismatch("timestamps_forecast must be equal to each exogenous_forecast.timestamps"))
        end
        return new{T}(parameters, 
                    dependent,
                    exogenous,
                    timestamps_forecast,
                    exogenous_forecast)
    end
end

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