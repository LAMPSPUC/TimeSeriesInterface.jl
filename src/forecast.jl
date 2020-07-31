export Forecast, 
    Scenarios

struct Forecast

end

struct Scenarios{T <: Real}
    name::String
    timestamps::Vector{DateTime}
    vals::Matrix{T}

    function Scenarios(name::String,
                       timestamps::Vector{DateTime},
                       vals::Matrix{T}) where T <: Real

        if length(timestamps) != size(vals, 1)
            throw(DimensionMismatch("timestamps and values do not have the same length."))
        end

        if !allunique(timestamps)
            throw(ErrorException("timestamps must be unique."))
        end

        if !issorted(timestamps)
            throw(ErrorException("timestamps must be sorted."))
        end

        return new{T}(name, timestamps, vals)
    end
end