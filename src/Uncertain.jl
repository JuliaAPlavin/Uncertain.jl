module Uncertain

export U, ±ᵤ

using Accessors

include("types.jl")
include("show.jl")
include("maths.jl")
include("agg.jl")
include("twosided.jl")
include("uncertainty_transformations.jl")
include("disambiguation.jl")

"""    ±ᵤ(val, unc)

Alias for the `Value(val, unc)` constructor.
"""
±ᵤ(v, e) = Value(v, e)

Base.promote_rule(::Type{<:ValueNumber{TM,SM}}, ::Type{T}) where {T<:Number,TM,SM} = ValueNumber{promote_type(T, TM), promote_type(real(T), SM)}
Base.promote_rule(::Type{T2}, ::Type{Complex{T1}}) where {T1,TM,SM,T2<:ValueNumber{TM,SM}} = Complex{real(promote_type(T1, T2))}
Base.promote_rule(::Type{<:ValueReal{TM,SM}}, ::Type{T}) where {T<:Real,TM,SM} = ValueReal{promote_type(T, TM), promote_type(real(T), SM)}
Base.promote_rule(::Type{<:ValueReal{T1,S1}}, ::Type{<:ValueReal{T2,S2}}) where {T1,T2,S1,S2} = ValueReal{promote_type(T1, T2), promote_type(S1, S2)}
Base.promote_rule(::Type{<:ValueNumber{T1,S1}}, ::Type{<:ValueNumber{T2,S2}}) where {T1,T2,S1,S2} = ValueNumber{promote_type(T1, T2), promote_type(S1, S2)}
Base.promote_rule(::Type{<:ValueReal{T1,S1}}, ::Type{<:ValueNumber{T2,S2}}) where {T1,T2,S1,S2} = ValueNumber{promote_type(T1, T2), promote_type(S1, S2)}
Base.promote_rule(::Type{<:ValueNumber{T2,S2}}, ::Type{<:ValueReal{T1,S1}}) where {T1,T2,S1,S2} = ValueNumber{promote_type(T1, T2), promote_type(S1, S2)}
Base.promote_rule(::Type{<:ValueAny{T1,S1}}, ::Type{<:ValueAny{T2,S2}}) where {T1,T2,S1,S2} = ValueAny{promote_type(T1, T2), promote_type(S1, S2)}

"""    nσ(x)

How many uncertainties `x` is away from zero. For numeric values, this is `abs(U.value(x)) / U.uncertainty(x)`.
"""
nσ(x) = abs(U.value(x)) / U.uncertainty(x)

"""    width(uncertainty)

The width of an uncertainty object: e.g., `2u` for `u` being a number, or `lo + hi` for `TwoSided`.
Only make sense for numbers with a natural order.
"""
function width end

"""    maxdiff(uncertainty)

Maximum difference from the nominal value allowed by an uncertainty object.
Assumes the natural norm for the values, e.g., `abs` for `Number`.
"""
function maxdiff end

width(a::Number) = 2a
maxdiff(a::Number) = a

function add end
# add(a::Number, b::Number) = a + b

# like sign(), but always +-1 and always an Int
_sign1i(x) = x < zero(x) ? -1 : 1


baremodule U
export Value, ValueAny, ValueNumber, ValueReal, value, uncertainty, nσ, weightedmean, ±
using ..Uncertain:
    Value, ValueAny, ValueNumber, ValueReal,
    UncertaintyTransformation, LinearAdd,
    value, uncertainty, nσ,
    weightedmean,
    TwoSided, width, maxdiff, reverse, add
using ..Uncertain: ±ᵤ as ±
end


end
