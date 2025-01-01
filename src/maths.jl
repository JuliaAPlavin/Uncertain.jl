assume_independent() = true

require(f, ::typeof(assume_independent)) =
    assume_independent() || error("""
    The `$f` operation is only correct for independent `Uncertain.Value`s, and we have no way to prove the independence automatically.
    Set `Uncertain.assume_independent() = true` to execute such functions.
    """)

const _v = value
const _Δ = uncertainty

# multiplication with the "strong zero" treatment of the 2nd argument
# useful for multiplying the derivative by the argument uncertainty, to avoid Infs and NaNs when the uncertainty is zero
*₀(a, b) = iszero(b) ? zero(a*b) : a*b

Base.:+(a::Value, b::Value) = (require(+, assume_independent); Value(_v(a) + _v(b), hypot(_Δ(a), _Δ(b))))
Base.:+(a::Value, b::Number) = Value(_v(a) + _v(b), _Δ(a))
Base.:+(a::Number, b::Value) = Value(_v(a) + _v(b), _Δ(b))

Base.:-(a::Value, b::Value) = (require(-, assume_independent); Value(_v(a) - _v(b), hypot(_Δ(a), _Δ(b))))
Base.:-(a::Value, b::Number) = Value(_v(a) - _v(b), _Δ(a))
Base.:-(a::Number, b::Value) = Value(_v(a) - _v(b), _Δ(b))

Base.:-(a::Value) = Value(-_v(a), _Δ(a))

Base.inv(a::Value) = Value(inv(_v(a)), abs2(inv(_v(a))) *₀ _Δ(a))

Base.:*(a::Value, b::Number) = Value(_v(a) * b, abs(b) *₀ _Δ(a))
Base.:*(a::Number, b::Value) = Value(a * _v(b), abs(a) *₀ _Δ(b))
Base.:/(a::Value, b::Number) = Value(_v(a) / b, abs(inv(b)) *₀ _Δ(a))
Base.:/(a::Number, b::Value) = Value(a / _v(b), abs(a) / _v(b)^2 *₀ _Δ(b))

Base.:*(a::Value, b::Value) = let
    require(*, assume_independent)
    x = _v(a) * _v(b)
    σ = hypot(_v(b) *₀ _Δ(a), _v(a) *₀ _Δ(b))
    Value(x, σ)
end

Base.:/(a::Value, b::Value) = let
    require(/, assume_independent)
    x = _v(a) / _v(b)
    σ = hypot(inv(_v(b)) *₀ _Δ(a), _v(a) / _v(b)^2 *₀ _Δ(b))
    Value(x, σ)
end

for T in [Integer, Real]
    # Integer for disambiguation with Base
    @eval Base.:^(a::Value, b::$T) = let
        Value(_v(a)^b, abs(_v(a) ^ (b - one(b)) * b) *₀ _Δ(a))
    end
end

Base.:^(a::Real,  b::Value) = let
    val = a ^ _v(b)
    Value(val, abs(val * log(a)) * _Δ(b))
end
Base.:^(a::Value, b::Value) = let
    require(^, assume_independent)
    val = _v(a) ^ _v(b)
    return Value(val, hypot(_v(a) ^ (_v(b) - one(_v(b))) * _v(b) *₀ _Δ(a), val * log(_v(a)) *₀ _Δ(b)))
end
Base.:^(::Irrational{:ℯ}, b::Value) = exp(b)

Base.sqrt(a::Value) = let
    val = sqrt(_v(a))
    Value(val, abs(inv(2 * val)) *₀ _Δ(a))
end


Base.log(a::Value) = Value(log(_v(a)), abs(inv(_v(a))) *₀ _Δ(a))
Base.log2(a::Value) = Value(log2(_v(a)), abs(inv(log(oftype(_v(a), 2)) * _v(a))) *₀ _Δ(a))
Base.log10(a::Value) = Value(log10(_v(a)), abs(inv(log(oftype(_v(a), 10)) * _v(a))) *₀ _Δ(a))
Base.exp(a::Value) = let
    val = exp(_v(a))
    Value(val, val *₀ _Δ(a))
end

Base.sin(a::Value) = Value(sin(_v(a)), abs(cos(_v(a))) *₀ _Δ(a))
Base.cos(a::Value) = Value(cos(_v(a)), abs(sin(_v(a))) *₀ _Δ(a))
Base.tan(a::Value) = Value(tan(_v(a)), abs2(sec(_v(a))) *₀ _Δ(a))
Base.asin(a::Value) = Value(asin(_v(a)), inv(sqrt(one(_v(a)) - abs2(_v(a)))) * _Δ(a))
Base.acos(a::Value) = Value(acos(_v(a)), inv(sqrt(one(_v(a)) - abs2(_v(a)))) * _Δ(a))

Base.sincos(a::Value) = sin(a), cos(a)
Base.cis(a::Value) = cos(a) + im * sin(a)

Base.atan(a::Value) = Value(atan(_v(a)), inv(abs2(_v(a)) + one(_v(a))) *₀ _Δ(a))
Base.atan(a::Value, b::Value) = let
    require(atan, assume_independent)
    denom = abs2(_v(a)) + abs2(_v(b))
    Value(atan(_v(a), _v(b)), hypot(_v(b)/denom *₀ _Δ(a), _v(a)/denom *₀ _Δ(b)))
end
Base.atan(a::Value, b::Real) = Value(atan(_v(a), b), abs(b) / (abs2(_v(a)) + abs2(b)) *₀ _Δ(a))
Base.atan(a::Real, b::Value) = Value(atan(a, _v(b)), abs(a) / (abs2(a) + abs2(_v(b))) *₀ _Δ(b))

Base.hypot(a::Value, b::Value) = let
    require(hypot, assume_independent)
    val = hypot(_v(a), _v(b))
    Value(val, hypot(_v(a) / val *₀ _Δ(a), _v(b) / val *₀ _Δ(b)))
end
Base.hypot(a::Value, b::Real) = let
    val = hypot(_v(a), b)
    Value(val, abs(_v(a)) / val * _Δ(a))
end
Base.hypot(a::Real, b::Value) = let
    val = hypot(a, _v(b))
    Value(val, abs(_v(b)) / val * _Δ(b))
end

Base.mod(x::Value, y::Value) = error("mod(x, y::Value) is not supported")
Base.mod(x::Real, y::Value) = error("mod(x, y::Value) is not supported")
Base.mod(x::Value, y::Real) = Value(mod(_v(x), y), _Δ(x))
Base.mod2pi(x::Value) = Value(mod2pi(_v(x)), _Δ(x))

Base.sign(x::Value) = sign(_v(x))
Base.abs(x::Value) = Value(abs(_v(x)), _Δ(x))
Base.abs2(x::Value) = Value(abs2(_v(x)), 2 * abs(_v(x)) *₀ _Δ(x))
Base.angle(x::Value) = Value(angle(_v(x)), _Δ(x)/abs(_v(x)))

for f in [:<, :isless, :isequal]
    for T in [:Value, :Number, :Rational, :Real, :AbstractFloat]
        @eval Base.$f(a::Value, b::$T) = $f(_v(a), _v(b))
        T != :Value && @eval Base.$f(a::$T, b::Value) = $f(_v(a), _v(b))
    end
end

for T in [:Value] # , :Number, :Rational, :Real, :AbstractFloat]
    # same code as for AbstractFloats in Base
    Base.min(x::Value, y::Value) = isnan(x) || ~isnan(y) && isless(x, y) ? x : y
    Base.max(x::Value, y::Value) = isnan(x) || ~isnan(y) && isless(y, x) ? x : y
end

for f in [:isnan, :isfinite]
    @eval Base.$f(x::Value) = $f(_v(x))
end

for f in [:conj, :real, :imag]
    @eval Base.$f(x::Value) = @modify($f, _v(x))
end

Base.deg2rad(a::Value) = Value(deg2rad(_v(a)), deg2rad(_Δ(a)))
Base.rad2deg(a::Value) = Value(rad2deg(_v(a)), rad2deg(_Δ(a)))
