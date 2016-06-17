"""
    makedata(M, N, both=DataFrame(), withinS=DataFrame(), withinI=DataFrame())
Generate a data frame of `M` subjects (`S`) crossed with `N` items.  The `both`
covariates are within subject and within item.  The `withinS` covariates are within
subject only and the `withinI` covariates are within item only.

In this version arguments `withinS` and `withinI` are ignored.

# Examples
```julia
julia> dat = makedata(50, 20, DataFrame(C = [-0.5, 0.5]));

julia> dump(dat)
DataFrames.DataFrame  2000 observations of 4 variables
  C: DataArrays.DataArray{Float64,1}(2000) [-0.5,0.5,-0.5,0.5]
  I: DataArrays.PooledDataArray{Int64,UInt8,1}(2000) [1,1,2,2]
  S: DataArrays.PooledDataArray{Int64,UInt8,1}(2000) [1,1,1,1]
  y: DataArrays.DataArray{Float64,1}(2000) [0.0,0.0,0.0,0.0]
```
"""
function makedata(M, N, both = DataFrame(), withinS = DataFrame(), withinI = DataFrame())
    nr = nrow(both)
    res = both[repeat(collect(1 : nr), outer = [M * N]), :]
    res[:I] = pool(repeat(collect(1 : N), inner = [nr], outer = [M]))
    res[:S] = pool(repeat(collect(1 : M), inner = [nr * N]))
    res[:y] = zeros(nr * M * N)
    res
end

"""
    makeΘ(Σ, σ)
Convert a random-effects covariance matrix `Σ` to a relative covariance factor, `Λ` and
extract the elements (in column-major order) of the lower triangle.  Only the lower triangle
of `Σ` is used.

# Examples
```
julia> makeθ(hcat([100^2, 60 * 100], [0, 100^2]), 300)
3-element Array{Float64,1}:
 0.333333
 0.2
 0.266667
```
"""
function makeθ(Σ, σ)
    n = size(Σ, 2)
    Λ = cholfact(Σ, :L).factors
    θ = sizehint!(eltype(Λ)[], (n * (n + 1)) >>> 1)
    for j in 1 : n, i in j : n
        push!(θ, Λ[i, j] / σ)
    end
    θ
end
