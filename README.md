# Uncertain.jl

> [!IMPORTANT]
> Handle uncertain values with ease and performance!

The most common case is numbers with measurement errors. `Uncertain.jl` only exports the `±ᵤ` operator and the `U` module that contains other useful symbols:
```julia
julia> 1 ±ᵤ 0.1  # not `±` so that not to clash with the popular `IntervalSets.jl` package
1.0 ± 0.1

julia> typeof(1 ±ᵤ 0.1)
Uncertain.ValueReal{Float64, Float64}

julia> U.value(1 ±ᵤ 0.1)
1.0

julia> U.uncertainty(1 ±ᵤ 0.1)
0.1
```

## Scope

The ultimate goal of `Uncertain.jl` is to support arbitrary uncertainty specifications – asymmetric errors, intervals, more complex distributions, and go beyond plain numbers. All within a single uniform interface.

Currently, aside from plain numbers, `Uncertain` provides the `U.TwoSided(lo, hi)` objects to represent asymmetric two-sided uncertainties. The companion `UncertainSkyCoords.jl` package provides uncertainties specific to `SkyCoords.jl` objects – basically, sky regions with different shapes. These types do not support _all_ operations where error propagation would make sense yet; reports and suggestions on specific missing operations are welcome!

Furthermore, `Uncertain.jl` provides integrations with other parts of the Julia ecosystem:
- Plotting with `Makie` – you should be able to pass uncertain values to any recipe where it makes sense
- Conversions to and from `IntervalSets.jl`, `Measurements.jl` and `MonteCarloMeasurements.jl` objects for ease of interoperability
- `Uncertain.Value`s with `Unitful.jl` quantities inside them support the `Unitful.jl` interface

## Relation to other uncertainty packages

The fundamental design difference of `Uncertain.jl`, compared to other Julia packages in this field like `Measurements.jl` and `MonteCarloMeasurements.jl`, is low overhead. It handles huge datasets of values with uncertainties. They occupy only 2x more memory than regular values, and have a performance overhead of only a factor of a few.
```julia
julia> n = 10^6
julia> x = rand(n)
julia> xu = x .±ᵤ 0.1

julia> Base.summarysize(x)
8000040

julia> Base.summarysize(xu)
16000040

julia> @b x .+ 1
482.584 μs (4 allocs: 7.629 MiB)

julia> @b xu .+ 1
1.201 ms (4 allocs: 15.259 MiB)
```
Other packages tend to have orders-of-magnitude overhead: `Measurements.jl` because they handle linear correlations, and `MonteCarloMeasurements.jl` because they use Monte-Carlo samples to represent uncertainties.

Those other packages have a much higher performance overhead, but they certainly have advantages over `Uncertain.jl`. In particular, here we only handle operations on independent uncertain values. All functions that involve only one uncertain number like `exp(x::Uncertain.Value)` or `x::Uncertain.Value + y::Float64` are automatically correct as there are no dependencies possible. Computing multivariate functions like `x::Uncertain.Value + y::Uncertain.Value` correctly requires accounting for correlations in the general case; we do not do that here. We have a flag one can set to control whether to assume independent values, or fail on these operations:
```julia
julia> Uncertain.assume_independent() = false

julia> x = 1 ±ᵤ 0.1
julia> y = 2 ±ᵤ 0.5

julia> x + y
ERROR: The `+` operation is only correct for independent `Uncertain.Value`s, and we have no way to prove the independence automatically.
Set `Uncertain.assume_independent() = true` to execute such functions.

julia> Uncertain.assume_independent() = true

julia> x + y
3.0 ± 0.5099019513592785
```

Naturally, the choice of which package to use is different in different scenarios. `Uncertain.jl` values can easily be converted back and forth to corresponding objects of other packages, making the interoperability more straightforward.
