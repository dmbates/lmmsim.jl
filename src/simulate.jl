"""
    simulate(N, models::OrderedDict{Symbol,LinearMixedModel}, saveresults::Function, β, σ, θ)
`N` replications of data are simulated from model `sim` in the ordered dictionary
`models` using the parameter values `β`, `σ` and `θ`.  All the models are fit to
this response, after which `saveresults` is called with arguments `models` and `i`,
the current index in the range `1:N`.   A simple `saveresults` callback would insert
the current value of the objective (i.e. -2*loglikelihood(m)) in a
`length(models) × N` array.
"""
function simulate(N, models::OrderedDict{Symbol,LinearMixedModel}, sim::Symbol,
                  saveresults::Function, β, σ, θ)
    simmod = models[sim]
    for i in 1 : N
        y = simulate!(simmod, β = β, σ = σ, θ = θ)
        for m in values(models)
            refit!(m, y)
        end
        saveresults(models, i)
    end
end

const dat = makedata(50, 20, DataFrame(C = [-0.5, 0.5]));

const mods = OrderedDict{Symbol, LinearMixedModel}(
    :max1 => lmm(y ~ 1 + C + (1 + C | S) + (1 + C | I), dat),
    :max0 => lmm(y ~ 1 + (1 + C | S) + (1 + C | I), dat),
    :nrc1 => lmm(y ~ 1 + C + (1 | S) + (0 + C | S) + (1 | I) + (0 + C | I), dat),
    :nrc0 => lmm(y ~ 1 + (1 | S) + (0 + C | S) + (1 | I) + (0 + C | I), dat),
    :zis1 => lmm(y ~ 1 + C + (1 | S) + (0 + C | S) + (1 | I), dat),
    :zis0 => lmm(y ~ 1 + (1 | S) + (0 + C | S) + (1 | I), dat),
#    :zss1 => lmm(y ~ 1 + C + (1 | S) + (1 | I) + (0 + C | I), dat),  # currently fails in refit
#    :zss0 => lmm(y ~ 1 + (1 | S) + (1 | I) + (0 + C | I), dat),  # currently fails in refit
    :rin1 => lmm(y ~ 1 + C + (1 | S) + (1 | I), dat),
    :rin0 => lmm(y ~ 1 + (1 | S) + (1 | I), dat)
)
