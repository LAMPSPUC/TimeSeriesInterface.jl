export hourly_to_monthly
export monthly_to_hourly

"""
Function to convert an hourly timeseries to a monthly timeseries, using an aggregate function.
"""
function hourly_to_monthly(time_series::TimeSeries; agg_func::Function=mean)
    name = time_series.name
    first = DateTime(year(time_series.timestamps[1]), month(time_series.timestamps[1]), 1)
    last = DateTime(year(time_series.timestamps[end]), month(time_series.timestamps[end]), 1)
    timestamps = collect(first:Month(1):last)
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
    first = DateTime(year(time_series.timestamps[1]), month(time_series.timestamps[1]), 1)
    last = DateTime(year(time_series.timestamps[end]), month(time_series.timestamps[end]), 1) + Month(1) - Hour(1)
    timestamps = collect(first:Hour(1):last)
    vals = Vector{Float64}(undef, length(timestamps))
    for i = 1:length(time_series.timestamps)
        vals[(timestamps .>= time_series.timestamps[i]) .& (timestamps .< (time_series.timestamps[i]+Month(1)))] .= time_series.vals[i]
    end
    return TimeSeries(name, timestamps, vals)
end