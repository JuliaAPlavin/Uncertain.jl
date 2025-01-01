module UnitfulExt

using Unitful
using Uncertain

Unitful.unit(x::U.Value) = unit(U.value(x))
Unitful.ustrip(x::U.Value) = ustrip(unit(x), x)
Unitful.ustrip(u::Unitful.Units, x::U.Value) = U.Value(ustrip(u, U.value(x)), ustrip(u, U.uncertainty(x)))

end
