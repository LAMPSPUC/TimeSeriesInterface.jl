module TimeSeriesInterface

import Base: +, - , *

using Dates

include("timeseries.jl")
include("FileFormats/FileFormats.jl")
include("granularity.jl")

end