module TimeSeriesInterface

import Base: +, - , *

using Dates, Statistics

include("timeseries.jl")
include("FileFormats/FileFormats.jl")

end