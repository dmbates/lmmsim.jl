# lmmsim

Linear mixed model simulations

[![Build Status](https://travis-ci.org/dmbates/lmmsim.jl.svg?branch=master)](https://travis-ci.org/dmbates/lmmsim.jl)

This simple package provides functions for creating the data frame and parameters to be used in
a simulation of linear mixed-effects models with crossed random effects for `Subject` and `Item`,
such as occur in experimental psychology and psycholinguistics.

The `makedata` function creates a data frame with fully crossed subject and item categories
plus whatever experimental factors are specified.  The response, `y`, in the data frame is initialized to
zeros.

`simulate` takes an `OrderedDict` of models, simulates data from one of them then refits all the
models to this data and applies an extractor.

The `dat` DataFrame and the `mods` OrderedDict are examples of data and models.

The package provides a `simulate` function that uses a callback function to save model results
after every iteration.  A callback can look like.

```julia
julia> using DataFrames, DataStructures, lmmsim, MixedModels

julia> N = 200;

julia> const objectives = zeros(length(mods), N);

julia> function callback(mods::OrderedDict{Symbol, LinearMixedModel}, j)
           for (i, m) in enumerate(values(mods))
               objectives[i, j] = objective(m)
           end
       end

julia> for m in values(mods)  # cause compilation of the model-fitting functions
           refit!(m, rand(nrow(dat)))
       end

julia> srand(1234321);

julia> @time simulate(N, mods, :rin1, callback, [2000., 20.], 300., [1/3, 1/3])
 22.590920 seconds (98.33 M allocations: 2.105 GB, 1.23% gc time)

julia> objectives
8x200 Array{Float64,2}:
 28639.5  28622.5  28611.5  28645.7  28648.4  28600.0  …  28619.0  28744.1  28543.4  28671.5  28532.1
 28641.2  28622.5  28613.8  28649.3  28648.7  28600.9     28621.1  28744.5  28545.0  28674.3  28537.1
 28639.9  28624.3  28614.9  28648.6  28653.3  28601.0     28619.1  28747.2  28547.9  28674.1  28533.5
 28641.5  28624.3  28617.4  28652.3  28653.6  28601.9     28621.1  28747.7  28549.8  28677.2  28538.6
 28639.9  28625.8  28614.9  28648.6  28654.1  28601.2     28619.9  28748.1  28548.0  28674.1  28533.6
 28641.8  28625.8  28617.7  28652.4  28654.5  28602.2  …  28622.8  28748.7  28550.0  28677.2  28539.4
 28639.9  28625.8  28614.9  28649.1  28654.2  28601.2     28619.9  28748.1  28548.0  28674.1  28534.1
 28641.8  28625.8  28617.7  28653.5  28654.6  28602.2     28622.8  28748.7  28550.0  28677.2  28541.1
```

An alternative is to create a function patterned on `simulate` that creates the storage and saves the
results in line, rather than through a callback.
