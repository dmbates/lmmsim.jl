module lmmsim

using DataFrames, DataStructures, MixedModels
export
    dat,
    makedata,
    makeθ,
    mods,
    simulate

include("makedata.jl")
include("simulate.jl")

end # module
