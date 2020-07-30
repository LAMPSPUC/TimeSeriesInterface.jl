using Dates

include("structs.jl")

function json_to_input(input_json)

    parameters          = input_json["parameters"]
    series_dependent    = build_input_series(input_json["series-dependent"])
    series_explanatory  = build_input_series(input_json["series-explanatory"])
    forecast_explantory = build_input_scenarios(input_json["forecast-explanatory"])

    return Input(parameters, series_dependent, series_explanatory, forecast_explantory)
end

function build_input_series(vec_series)
    dict_series = Dict()

    for serie in vec_series
        dict_series[serie["name"]] = input_series_to_dataframe(serie["time-serie"])
    end

    return dict_series
end

function input_series_to_dataframe(time_serie)
    num_observations = length(time_serie)
    m = Matrix{Any}(undef, num_observations, 2) 
    
    for i = 1:num_observations
        m[i, 1] = DateTime(time_serie[i]["timestamp"])
        m[i, 2] = time_serie[i]["value"]
    end

    return DataFrame(timestamp = m[:, 1], value = m[:, 2])
end

function input_scenarios_to_dataframe(time_scenarios)
    num_observations = length(time_scenarios)
    m = Matrix{Any}(undef, num_observations, length(time_scenarios[1]["scenarios"]) + 1)
    
    for i = 1:num_observations
        m[i, 1] = DateTime(time_scenarios[i]["timestamp"])
        m[i, 2:end] = time_scenarios[i]["scenarios"]
    end
    vec_name_scenarios = []
    for i = 1:length(time_scenarios[1]["scenarios"])
    end

    df = DataFrame(m)
    rename!(df, Vector{Symbol}(vcat(:timestamp,[Symbol(i) for i = 1:length(time_scenarios[1]["scenarios"])])))

    return df
end

function build_input_scenarios(vec_series)
    dict_series = Dict()

    for serie in vec_series
        dict_series[serie["name"]] = input_scenarios_to_dataframe(serie["time-serie"])
    end

    return dict_series
end