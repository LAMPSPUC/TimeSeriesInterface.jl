module TimeSeriesInterface

import Base: +, - , *

using Dates
using Statistics

include("timeseries.jl")
include("forecast.jl")
include("FileFormats/FileFormats.jl")

end