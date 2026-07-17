module UnitfulExt

using Unitful
using Uncertain

Uncertain._ustrip(x::U.Value{<:Union{Quantity, AbstractArray{<:Quantity}}}) = ustrip(x)
Unitful.unit(x::U.Value) = unit(U.value(x))
Unitful.ustrip(x::U.Value) = ustrip(unit(x), x)
Unitful.ustrip(u::Unitful.Units, x::U.Value) = U.Value(ustrip(u, U.value(x)), ustrip(u, U.uncertainty(x)))
Unitful.uconvert(u::Unitful.FreeUnits, x::U.Value) = U.Value(Unitful.uconvert(u, U.value(x)), Unitful.uconvert(u, U.uncertainty(x)))

Base.promote_rule(::Type{Quantity{S,D,U_}}, ::Type{<:U.ValueNumber{T,TE}}) where {S, D, U_, T, TE} =
    return U.ValueNumber{promote_type(Quantity{S,D,U_}, T), promote_type(Quantity{S,D,U_}, TE)}
Base.promote_rule(::Type{Quantity{S,D,U_}}, ::Type{<:U.ValueReal{T,TE}}) where {S, D, U_, T, TE} =
    return U.ValueReal{promote_type(Quantity{S,D,U_}, T), promote_type(Quantity{S,D,U_}, TE)}

function Base.:*(x::U.Value, y::Unitful.Units, z::Unitful.Units...)
    u = *(y, z...)
    U.Value(U.value(x) * u, U.uncertainty(x) * u)
end

# `Value` and `Unitful.Quantity` are both `<:Number`, so `Value op Quantity` and
# `Quantity op Value` are ambiguous between Uncertain's and Unitful's methods and need
# explicit definitions. Multiplication by an exact quantity scales the uncertainty by `|y|`;
# division is expressed as multiplication by the reciprocal, so `inv` (maths.jl) supplies the
# reciprocal propagation and there is no separate division rule to keep in sync.
Base.:*(x::U.Value, y::Unitful.Quantity) = U.Value(U.value(x) * y, U.uncertainty(x) * abs(y))
Base.:*(y::Unitful.Quantity, x::U.Value) = x * y
Base.:/(x::U.Value, y::Unitful.Quantity) = x * inv(y)
Base.:/(y::Unitful.Quantity, x::U.Value) = y * inv(x)

# A bare unit is not a `Number`; multiplying or dividing a `Value` by one simply
# attaches/rescales the unit on both components (exact).
Base.:*(x::U.Value, y::Unitful.FreeUnits) = U.Value(U.value(x) * y, U.uncertainty(x) * y)
Base.:/(x::U.Value, y::Unitful.FreeUnits) = U.Value(U.value(x) / y, U.uncertainty(x) / y)


Unitful.ustrip(u::Unitful.Units, e::U.CovMat) = U.CovMat(ustrip.(u^2, e.cov))
Unitful.uconvert(u, e::U.CovMat) = U.CovMat(uconvert.(u^2, e.cov))

Base.:*(mul::Unitful.FreeUnits, e::U.CovMat) = U.CovMat(mul^2 * e.cov)
Base.:*(e::U.CovMat, mul::Unitful.FreeUnits) = U.CovMat(e.cov * mul^2)
Base.:/(e::U.CovMat, mul::Unitful.FreeUnits) = U.CovMat(e.cov / mul^2)


# XXX: piracy, should be upstreamed
Unitful.unit(x::AbstractVector) = unit(eltype(x))
Unitful.uconvert(u::Unitful.Units, x::AbstractVector) = uconvert.(u, x)

end
