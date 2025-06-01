module MakieMonteCarloMeasurementsExt
# XXX: piracy, here only as a stopgap, should upstream to MCM

using Makie
import MonteCarloMeasurements as MCM
using MonteCarloMeasurements.StaticArrays: SVector

Makie.convert_arguments(p::Type{<:Union{Hist,StepHist,Density}}, x::MCM.Particles) = convert_arguments(p, Vector(x))

Makie.convert_arguments(ct::PointBased, x::AbstractVector{<:MCM.Particles}, y::AbstractVector{<:MCM.Particles}; avgfunc=MCM.pmedian) = convert_arguments(ct, avgfunc.(x), avgfunc.(y))
Makie.convert_arguments(ct::PointBased, x::AbstractVector{<:MCM.Particles}, y::AbstractVector{<:Real}; avgfunc=MCM.pmedian) = convert_arguments(ct, avgfunc.(x), y)

Makie.convert_arguments(ct::Type{<:Union{Rangebars,Band}}, x::AbstractVector{<:MCM.Particles}, y::AbstractVector{<:MCM.Particles}; avgfunc=MCM.pmedian, kwargs...) = convert_arguments(ct, avgfunc.(x), y; kwargs...)

Makie.convert_arguments(ct::Type{<:AbstractPlot}, X::AbstractVector{<:Tuple{<:MCM.Particles,<:Real}}; kwargs...) = convert_arguments(ct, first.(X), last.(X); kwargs...)
Makie.convert_arguments(ct::Type{<:AbstractPlot}, X::AbstractVector{<:Tuple{<:MCM.Particles,<:MCM.Particles}}; kwargs...) = convert_arguments(ct, first.(X), last.(X); kwargs...)
Makie.convert_arguments(ct::Type{<:AbstractPlot}, X::AbstractVector{<:SVector{2, <:MCM.Particles}}; kwargs...) = convert_arguments(ct, first.(X), last.(X); kwargs...)

# Makie.convert_arguments(ct::Type{<:Union{Rangebars,Band}}, xy::AbstractVector{<:SVector{2, <:MCM.Particles}}; q=nothing, nσ=nothing, avgf=MCM.pmedian)
#     !isnothing(q) && !isnothing(nσ) && throw(ArgumentError("Only one of `q`` or `nσ`` can be specified"))
#     if isnothing(q) && isnothing(nσ)
#         q = 0.16
#     end
#     if !isnothing(q)
#         convert_arguments(ct, avgf.(first.(xy)), MCM.pquantile.(last.(xy), q), MCM.pquantile.(last.(xy), 1-q))
#     elseif !isnothing(nσ)
#         avgs = MCM.pmean.(y)
#         Δs = nσ .* MCM.pstd.(y)
#         convert_arguments(ct, x, avgs .- Δs, avgs .+ Δs)
#     end
# end

end