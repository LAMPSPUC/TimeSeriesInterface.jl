using JSON

function write_json(file::String, dict::Dict) 
    open(file, "w") do f
        JSON.print(f, dict, 4)
    end
    return file
end


function output_to_json(output_struct)
    return 1
end


function output_to_dict(output_struct)
    output_dict = Dict()
    output_dict["hyperparameters"] = build_hyperparameters_vector(output_struct["hyperparameters"])
    
end

function build_hyperparameters_vector(hyper_dict)
    
    num_hyperparameters = length(keys(hyper_dict)) 
    vec_hyper = Vector{Dict}(undef, 0)

    for (key, struct_hyperparameters) in hyper_dict
        d = Dict()
        d["name"] = key
        d["value"] = struct_hyperparameters.value
        d["std-error"] = struct_hyperparameters.std_error
        d["p-value"] = struct_hyperparameters.p_value
        push!(vec_hyper, d)
    end
    
    return vec_hyper
end








output["hyperparameters"]["phi"] = HyperParameters(value,...)


dict["pho"] = HyperParameters(value,...)

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
    hyperparameters::Dict{String, HyperParameters}
    residuals::Dict{String, Dict{String, DataFrame}}
    fit_insample::Dict{String, DataFrame}
    forecast::Dict{String, Forecast}
end


v = Vector{Dict}(undef, 10)

v[1] = Dict()
v[1]["test"] = 1