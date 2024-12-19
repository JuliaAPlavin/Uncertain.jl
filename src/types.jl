struct ValueAny{T,TU}
    v::T
    u::TU
end

struct ValueNumber{T,TU} <: Number
    v::T
    u::TU
end

struct ValueReal{T,TU} <: Real
    v::T
    u::TU
end

const Value{T,TU} = Union{ValueAny{T,TU}, ValueNumber{T,TU}, ValueReal{T,TU}}

valtype(::Type{<:Value{T,TU}}) where {T,TU} = T
valtype(::Type{<:Value}) = Any
unctype(::Type{<:Value{T,TU}}) where {T,TU} = TU
unctype(::Type{<:Value}) = Any


Value(x, u) = ValueAny(x, u)
function Value(x::Number, u::Number)
    xp, up = promote(x, u)
    ValueNumber(xp, _check_u_valid(up))
end
function Value(x::Real, u::Number)
    xp, up = promote(x, u)
    ValueReal(xp, _check_u_valid(up))
end
Value(x::Number, u) = ValueNumber(x, u)
Value(x::Real, u) = ValueReal(x, u)

function _check_u_valid(u::Number)
    isreal(u) || throw(ArgumentError("uncertainty must be `isreal`, got $u"))
    u_ = real(u)
    !(u_ < zero(u_)) || throw(ArgumentError("uncertainty must be non-negative, got $u"))
    return u_
end

(::Type{T})(x::Value) where {T<:Value} = T(convert(valtype(T), x.v), convert(unctype(T), x.u))
(::Type{T})(x::Number) where {T<:Value} = T(convert(valtype(T), x), convert(unctype(T), zero(x)))


@accessor value(v::Value) = v.v
@accessor uncertainty(v::Value) = v.u
@inline value(x) = x
@inline uncertainty(x) = zero(x)

Base.broadcastable(x::Union{ValueNumber,ValueReal}) = Ref(x)

Base.:(==)(a::Value, b::Value) = a.v == b.v && a.u == b.u
