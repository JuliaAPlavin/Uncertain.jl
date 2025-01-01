module MonteCarloMeasurementsExt

import MonteCarloMeasurements as MCM
using Uncertain

(::Type{T})(x::MCM.Particles) where {T<:U.Value} = T(MCM.pmean(x), MCM.pstd(x))

MCM.Particles(n::Int, x::U.Value) = MCM.Particles(n, MCM.Normal(U.value(x), U.uncertainty(x)))

end
