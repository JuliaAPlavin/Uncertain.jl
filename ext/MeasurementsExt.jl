module MeasurementsExt

import Measurements
using Uncertain

(::Type{T})(x::Measurements.Measurement) where {T<:U.Value} = T(Measurements.value(x), Measurements.uncertainty(x))
Measurements.Measurement(x::U.Value) = Measurements.measurement(U.value(x), U.uncertainty(x))
Measurements.measurement(x::U.Value) = Measurements.Measurement(x)

end