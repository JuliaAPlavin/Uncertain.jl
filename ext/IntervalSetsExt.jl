module IntervalSetsExt

using IntervalSets
using Uncertain

IntervalSets.Interval(x::U.Value) = U.value(x) ± U.uncertainty(x)
(::Type{T})(x::Interval) where {T<:U.Value} = T((leftendpoint(x) + rightendpoint(x))/2, width(x) / 2)

end
