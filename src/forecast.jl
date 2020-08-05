export PointForecast, ScenariosForecast, QuantilesForecast

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