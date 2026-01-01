abstract type UncertaintyTransformation end

(t::UncertaintyTransformation)(x::Value) = @modify(t, uncertainty(x))

struct LinearAdd{T} <: UncertaintyTransformation
    add::T
end

(t::LinearAdd{<:Number})(u::Number) = u + t.add
(t::LinearAdd{<:Number})(u::TwoSided) = @modify(p -> p + t.add, u[∗ₚ])
