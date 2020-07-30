using DataFrames

mutable struct Input
    parameters::Dict{String, Any}
    series_dependent::Dict{String, DataFrame}
    series_explanatory::Dict{String, DataFrame}
    forecast_explantory::Dict{String, DataFrame}
end

mutable struct HyperParameters
    value::Float64
    std_error::Float64
    p_value::Float64
end

mutable struct Forecast
    forecast::DataFrame
    scenarios::DataFrame
end

mutable struct Output
    name_hyperparam::Vector{String}
    hyperparameters::Dict{String, HyperParameters}
    residuals::Dict{String, Dict{String, DataFrame}}
    fit_insample::Dict{String, DataFrame}
    forecast::Dict{String, Forecast}
end