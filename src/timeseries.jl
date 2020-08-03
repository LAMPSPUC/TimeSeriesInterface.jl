export TimeSeries

import Base: +, - , *

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

# auxiliar functions

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

# + functions

function create_new_vals_sum(time_series_vector, new_timestamps)
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

function sum_timeseries(time_series_vector)

    new_names      = create_new_name(time_series_vector,"+")
    new_timestamps = Vector{DateTime}(create_new_timestamps(time_series_vector))
    new_vals       = Vector{Float64}(create_new_vals_sum(time_series_vector, new_timestamps))

    return TimeSeries(new_names, new_timestamps, new_vals)
end

function (+)(ts1::TimeSeries, ts2::TimeSeries...)

    n_args = length(ts2)

    time_series_vector = [ts1]

    for n = 1:n_args
        push!(time_series_vector, ts2[n])
    end

    return sum_timeseries(time_series_vector)
end

# - functions

function create_new_vals_subtraction(time_series_vector, new_timestamps)
    num_of_time_series = length(time_series_vector)

    new_vals = []
    
    for tstamp in new_timestamps
        tstamp_val = []

        for num_ts = 1:num_of_time_series
            
            tserie = time_series_vector[num_ts]

            if num_ts == 1
                index = findall(x -> x == tstamp, tserie.timestamps)

                if !isempty(index)
                    push!(tstamp_val, tserie.vals[index[1]])
                end
            else
                index = findall(x -> x == tstamp, tserie.timestamps)

                if !isempty(index)
                    push!(tstamp_val, - tserie.vals[index[1]])
                end
            end
        end


        push!(new_vals, sum(tstamp_val))
    end

    return new_vals
end

function subtract_timeseries(time_series_vector)
    if length(time_series_vector) == 1
        new_names      = "- "*time_series_vector[1].name
        new_timestamps = time_series_vector[1].timestamps
        new_vals       = - time_series_vector[1].vals
    else
        new_names      = create_new_name(time_series_vector, "-")
        new_timestamps = Vector{DateTime}(create_new_timestamps(time_series_vector))
        new_vals       = Vector{Float64}(create_new_vals_subtraction(time_series_vector, new_timestamps))
    end

    return TimeSeries(new_names, new_timestamps, new_vals)
end

function (-)(ts1::TimeSeries, ts2::TimeSeries...)

    n_args = length(ts2)

    time_series_vector = [ts1]

    for n = 1:n_args
        push!(time_series_vector, ts2[n])
    end

    return subtract_timeseries(time_series_vector)
end


# * functions

function create_new_vals_product(time_series_vector, new_timestamps)
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

        push!(new_vals, prod(tstamp_val))
    end

    return new_vals
end

function product_timeseries(time_series_vector)
    new_names      = create_new_name(time_series_vector, "*")
    new_timestamps = Vector{DateTime}(create_new_timestamps(time_series_vector))
    new_vals       = Vector{Float64}(create_new_vals_product(time_series_vector, new_timestamps))

    return TimeSeries(new_names, new_timestamps, new_vals)
end

function (*)(ts1::TimeSeries, ts2::TimeSeries...)

    n_args = length(ts2)

    time_series_vector = [ts1]

    for n = 1:n_args
        push!(time_series_vector, ts2[n])
    end

    return product_timeseries(time_series_vector)
end


# Define a normalize function and some other useful

# Define some aggregations and disaggregation methods


ts1 = TimeSeries("Serie 1", [DateTime(i) for i = 1:10], [i+0.0 for i = 1:10])
ts2 = TimeSeries("Serie 2", [DateTime(i) for i = 11:20], [i+0.0 for i = 11:20])
ts3 = TimeSeries("Serie 3", [DateTime(i) for i = 1:20], [i+0.0 for i = 1:20])

