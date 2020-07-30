export TimeSeries

"""
    TimeSeries


"""
struct TimeSeries{T <: Real}
    name::String
    timestamps::Vector{DateTime}
    vals::Vector{T}

    function TimeSeries(name::String,
                        timestamps::Vector{DateTime},
                        vals::Vector{T}) where T <: Real

        if length(timestamps) != length(vals)
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

# Additional constructors
function TimeSeries(name::String,
                    timestamps::Vector{Date}, 
                    values::Vector{T}) where T
    return TimeSeries(name,
                      DateTime.(timestamps),
                      values)
end

name(ts::TimeSeries) = ts.name
timestamps(ts::TimeSeries) = ts.timestamps
values(ts::TimeSeries) = ts.values

# Define some nice functions like + - * and /

# Define a normalize function and some other useful

# Define some aggregations and disaggregation methods