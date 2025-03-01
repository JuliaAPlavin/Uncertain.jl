abstract type UncertaintyTransformation end

(t::UncertaintyTransformation)(x::Value) = @modify(t, uncertainty(x))

struct UncertaintyTransformationF{F} <: UncertaintyTransformation
    f::F
end

(t::UncertaintyTransformationF)(u) = t.f(u)
(t::UncertaintyTransformationF)(x::Value) = @modify(t, uncertainty(x))  # disambiguation

struct LinearAdd{T} <: UncertaintyTransformation
    add::T
end

(t::LinearAdd{<:Number})(u::Number) = u + t.add
(t::LinearAdd{<:Number})(u::TwoSided) = @modify(p -> p + t.add, u[∗ₚ])
(t::LinearAdd{<:Number})(x::Value) = @modify(t, uncertainty(x))  # disambiguation
