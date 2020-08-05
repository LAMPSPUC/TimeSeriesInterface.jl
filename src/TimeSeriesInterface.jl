module TimeSeriesInterface

import Base: +, - , *

using Dates

include("timeseries.jl")
include("forecast.jl")
include("FileFormats/FileFormats.jl")

end