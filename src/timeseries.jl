export TimeSeries
using Dates
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

function create_new_name(time_series_vector, string)
    num_of_time_series = length(time_series_vector)

    new_name = ""
    for n = 1:num_of_time_series
        if n != 1
            new_name = new_name*" "*string*" "*time_series_vector[n].name
        else
            new_name = new_name*time_series_vector[n].name
        end
    end

    return new_name
end

function create_new_timestamps(time_series_vector)
    num_of_time_series = length(time_series_vector)
    
    new_timestamps = []
    
    for n = 1:num_of_time_series
        new_timestamps = vcat(new_timestamps, time_series_vector[n].timestamps)
    end

    return sort(unique(new_timestamps))
end

function create_new_vals(time_series_vector, new_timestamps)
    num_of_time_series = length(time_series_vector)

    new_vals = []
    
    for tstamp in new_timestamps
        tstamp_val = []

        for tserie in time_series_vector

            index = findall(x -> x == tstamp, tserie.timestamps)

            if !isempty(index)
                push!(tstamp_val, tserie.vals[index[1]])
            end

        end

        push!(new_vals, sum(tstamp_val))
    end

    return new_vals
end

function Base.:+(ts1::TimeSeries, ts2::TimeSeries...)

    n_args = length(ts2)

    time_series_vector = [ts1]

    for n = 1:n_args
        push!(time_series_vector, ts2[n])
    end

    new_names      = create_new_name(time_series_vector,"+")
    new_timestamps = Vector{DateTime}(create_new_timestamps(time_series_vector))
    new_vals       = Vector{Float64}(create_new_vals(time_series_vector, new_timestamps))

    return TimeSeries(new_names, new_timestamps, new_vals)
end


# Define a normalize function and some other useful

# Define some aggregations and disaggregation methods


ts1 = TimeSeries("ENA", [DateTime(i) for i =1:5:1000], rand(200))

ts2 = TimeSeries("EAR", [DateTime(i) for i =1:10:1000], rand(100))

ts3 = TimeSeries("EAR", [DateTime(i) for i =1:3:300], rand(100))



ts4 = ts1 + ts2

ts1.vals[1]


ts4.vals[1] == ts1.vals[1] + ts2.vals[1]
ts4.vals[2] == ts1.vals[2]
ts4.vals[3] == ts1.vals[3] + ts2.vals[2]



plot(ts1.timestamps, ts1.vals)

using Plots


findall(x->x == 1, [2,3,4])


import Base 

