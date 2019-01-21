module PaperUtils

using DataFrames
import Missings: missing, skipmissing, ismissing
using Statistics

include("tables.jl")
include("critical_diagrams.jl")
include("rankings.jl")

end # module
