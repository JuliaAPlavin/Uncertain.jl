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

(::Type{T})(x::Value) where {T<:Value} = T(valtype(T)(x.v), unctype(T)(x.u))
(::Type{T})(x::Number) where {T<:Value} = T(valtype(T)(x), unctype(T)(zero(x)))
(::Type{T})(x) where {T<:Complex{<:Value}} = T(real(x), imag(x))

"""    value(x)

The nominal value of `x::Value`, or `x` itself if it's not a `Value`.
"""
function value end

"""    uncertainty(x)

The uncertainty of `x::Value`, or zero if it's not a `Value`.
"""
function uncertainty end

@accessor value(v::Value) = v.v
@accessor uncertainty(v::Value) = v.u
@accessor value(x) = x
uncertainty(x) = zero(real(x))
value(x::Complex{<:Value}) = Complex(value(x.re), value(x.im))
uncertainty(x::Complex{<:Value}) = Complex(uncertainty(x.re), uncertainty(x.im))

Base.float(::Type{V}) where {V<:Value} = ValueReal{float(valtype(V)), float(unctype(V))}
Base.float(x::Value) = U.Value(float(value(x)), float(uncertainty(x)))

Base.broadcastable(x::Union{ValueNumber,ValueReal}) = Ref(x)

Base.:(==)(a::Value, b::Value) = a.v == b.v && a.u == b.u
