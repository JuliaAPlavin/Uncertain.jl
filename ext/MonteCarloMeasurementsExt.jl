module MonteCarloMeasurementsExt

import MonteCarloMeasurements as MCM
using Uncertain
using LinearAlgebra: Symmetric, RowMaximum, cholesky, invperm

(::Type{T})(x::MCM.AbstractParticles) where {T<:U.Value} = T(MCM.pmean(x), MCM.pstd(x))

(::Type{PT})(n::Int, x::U.Value) where {PT <: MCM.AbstractParticles} = PT(n, MCM.Normal(U.value(x), U.uncertainty(x)))

# uconvert: scalar
U.uconvert(::Type{PT}, v, u::Number) where {PT <: MCM.AbstractParticles} = PT(MCM.Normal(v, u))
U.uconvert(::Type{PT}, v, u::Number) where {N, PT <: MCM.AbstractParticles{Any,N}} = _particletype(PT){float(promote_type(typeof(v), typeof(u))),N}(v .+ u .* randn(N))

# uconvert: vector + CovMat
U.uconvert(::Type{PT}, v::AbstractVector, u::U.CovMat) where {PT <: MCM.AbstractParticles} = _sample_covmat(PT, v, u, _default_n(PT))
U.uconvert(::Type{PT}, v::AbstractVector, u::U.CovMat) where {N, PT <: MCM.AbstractParticles{Any,N}} = _sample_covmat(_particletype(PT), v, u, N)

function _sample_covmat(::Type{PT}, v, u, n) where {PT <: MCM.AbstractParticles}
    Σ = u.cov
    c = cholesky(Σ isa Symmetric ? Σ : Symmetric(Σ), RowMaximum(); check=false)
    Lr = c.L[:, 1:c.rank]
    ip = invperm(c.p)
    samples = v .+ Lr[ip, :] * randn(c.rank, n)
    map((_, i) -> PT(samples[i, :]), v, eachindex(v))
end

_particletype(::Type{<:MCM.Particles}) = MCM.Particles
_particletype(::Type{<:MCM.StaticParticles}) = MCM.StaticParticles
_default_n(::Type{PT}) where {PT <: MCM.AbstractParticles} = MCM.nparticles(PT(MCM.Normal(0, 1)))

end
