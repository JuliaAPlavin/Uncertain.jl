module MonteCarloMeasurementsExt

import MonteCarloMeasurements as MCM
using Uncertain

(::Type{T})(x::MCM.AbstractParticles) where {T<:U.Value} = T(MCM.pmean(x), MCM.pstd(x))

(::Type{PT})(n::Int, x::U.Value) where {PT <: MCM.AbstractParticles} = PT(n, MCM.Normal(U.value(x), U.uncertainty(x)))

end
