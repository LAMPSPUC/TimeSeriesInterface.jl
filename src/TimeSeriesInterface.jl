module TimeSeriesInterface

import Base: +, -, *

using Dates
using RecipesBase
using Statistics

include("timeseries.jl")
include("models.jl")
include("forecast.jl")
include("FileFormats/FileFormats.jl")

end