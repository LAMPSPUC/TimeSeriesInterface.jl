const PLOTSIZE = (1000, 500)

RecipesBase.@recipe function f(ts::TimeSeries{T};
                               title="Time Series", 
                               y_unit="y") where T
    size --> PLOTSIZE
    xguide --> "timestamps"
    yguide --> y_unit
    label --> ts.name
    @series begin
        # force an argument with `:=`
        seriestype := :path
        # return series data
        return ts.timestamps, ts.vals
    end
end
RecipesBase.@recipe function f(vec_ts::Vector{TimeSeries{T}}; 
                               title="Time Series", 
                               y_unit="y") where T
    size --> PLOTSIZE
    xguide --> "timestamps"
    yguide --> y_unit
    for ts in vec_ts
        RecipesBase.@series begin
            label := ts.name
            return ts.timestamps, ts.vals
        end
    end
end