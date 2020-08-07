export TimeSeries
export hourly_to_monthly
export monthly_to_hourly

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
function verify_if_ts_are_equal(ts1::TimeSeries{T}, ts2::TimeSeries{T}) where T
    return ts1.name == ts2.name && ts1.timestamps == ts2.timestamps && ts1.vals == ts2.vals
end

function create_ts_name_from_ts_vector(time_series_vector, string)
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

function union_timestamps(time_series_vector)
    num_of_time_series = length(time_series_vector)
    
    new_timestamps = DateTime[]
    
    for n = 1:num_of_time_series
        new_timestamps = vcat(new_timestamps, time_series_vector[n].timestamps)
    end

    return sort(unique(new_timestamps))
end

# + functions

function sum_vals_from_ts_vector(time_series_vector::Vector{TimeSeries{T}}, new_timestamps) where T
    num_of_time_series = length(time_series_vector)

    new_vals = T[]
    
    for tstamp in new_timestamps
        tstamp_val = T[]

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

function sum_ts(time_series_vector)

    new_names      = create_ts_name_from_ts_vector(time_series_vector,"+")
    new_timestamps = union_timestamps(time_series_vector)
    new_vals       = sum_vals_from_ts_vector(time_series_vector, new_timestamps)

    return TimeSeries(new_names, new_timestamps, new_vals)
end

function (+)(ts1::TimeSeries, ts2::TimeSeries...)

    n_args = length(ts2)

    time_series_vector = [ts1]

    for n = 1:n_args
        push!(time_series_vector, ts2[n])
    end

    return sum_ts(time_series_vector)
end

# - functions

function subtract_vals_from_ts_vector(time_series_vector::Vector{TimeSeries{T}}, new_timestamps) where T
    num_of_time_series = length(time_series_vector)

    new_vals = T[]
    
    for tstamp in new_timestamps
        tstamp_val = T[]

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

function subtract_ts(time_series_vector)
    if length(time_series_vector) == 1
        new_names      = "- "*time_series_vector[1].name
        new_timestamps = time_series_vector[1].timestamps
        new_vals       = - time_series_vector[1].vals
    else
        new_names      = create_ts_name_from_ts_vector(time_series_vector, "-")
        new_timestamps = union_timestamps(time_series_vector)
        new_vals       = subtract_vals_from_ts_vector(time_series_vector, new_timestamps)
    end

    return TimeSeries(new_names, new_timestamps, new_vals)
end

function (-)(ts1::TimeSeries, ts2::TimeSeries...)

    n_args = length(ts2)

    time_series_vector = [ts1]

    for n = 1:n_args
        push!(time_series_vector, ts2[n])
    end

    return subtract_ts(time_series_vector)
end


# * functions

function multiply_vals_from_ts_vector(time_series_vector::Vector{TimeSeries{T}}, new_timestamps) where T
    num_of_time_series = length(time_series_vector)

    new_vals = T[]
    
    for tstamp in new_timestamps
        tstamp_val = T[]

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

function product_ts(time_series_vector)
    new_names      = create_ts_name_from_ts_vector(time_series_vector, "*")
    new_timestamps = union_timestamps(time_series_vector)
    new_vals       = multiply_vals_from_ts_vector(time_series_vector, new_timestamps)

    return TimeSeries(new_names, new_timestamps, new_vals)
end

function (*)(ts1::TimeSeries, ts2::TimeSeries...)

    n_args = length(ts2)

    time_series_vector = [ts1]

    for n = 1:n_args
        push!(time_series_vector, ts2[n])
    end

    return product_ts(time_series_vector)
end

function observations_close_to_zero(ts::TimeSeries; zero_threshold = 1e-8)
    for v in ts.vals
        if (v <= zero_threshold) && (v >= -zero_threshold)
            return true
        end
    end
    return false
end
# Define a normalize function and some other useful

# Define some aggregations and disaggregation methods

"""
Function to convert an hourly timeseries to a monthly timeseries, using an aggregate function.
"""
function hourly_to_monthly(time_series::TimeSeries; agg_func::Function=mean)
    name = time_series.name
    timestamps = map(x -> DateTime(x...), unique(yearmonth.(time_series.timestamps)))
    vals = Vector{Float64}(undef, length(timestamps))
    for i = 1:length(timestamps)
        vals[i] = agg_func(time_series.vals[(time_series.timestamps .>= timestamps[i]) .& (time_series.timestamps .< (timestamps[i] + Month(1)))])
    end
    return TimeSeries(name, timestamps, vals)
end

"""
Function to convert a monthly timeseries to an hourly timeseries.
"""
function monthly_to_hourly(time_series::TimeSeries)
    name = time_series.name
    timestamps = Vector{DateTime}(undef, 0)
    for m in yearmonth.(time_series.timestamps)
        append!(timestamps, collect(firstdayofmonth(DateTime(m...)):Hour(1):(lastdayofmonth(DateTime(m...))+Hour(23))))
    end

    vals = Vector{Float64}(undef, length(timestamps))
    for i = 1:length(time_series.timestamps)
        vals[(timestamps .>= time_series.timestamps[i]) .& (timestamps .< (time_series.timestamps[i]+Month(1)))] .= time_series.vals[i]
    end
    return TimeSeries(name, timestamps, vals)
end