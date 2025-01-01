(::Type{T})(x::Complex) where {T<:ValueReal} = T(Real(x))

(::Type{T})(x::Complex) where {T<:Complex{<:Value}} = @invoke T(x::Number)
(::Type{T})(x::Real) where {T<:Complex{<:ValueReal}} = @invoke T(x::Number)
(::Type{T})(x::AbstractIrrational) where {T<:Complex{<:ValueReal}} = @invoke T(x::Number)

Base.isequal(a::Complex, b::ValueReal) = @invoke isequal(a, b::Value)
Base.isequal(a::ValueReal, b::Complex) = @invoke isequal(a::Value, b)

Base.:+(a::Complex, b::ValueReal) = @invoke +(a::Number, b)
Base.:+(a::Complex{Bool}, b::ValueReal) = @invoke +(a::Complex, b)
Base.:+(a::ValueReal, b::Complex) = @invoke +(a, b::Number)
Base.:+(a::ValueReal, b::Complex{Bool}) = @invoke +(a, b::Complex)

Base.:-(a::Complex, b::ValueReal) = @invoke -(a::Number, b)
Base.:-(a::Complex{Bool}, b::ValueReal) = @invoke -(a::Complex, b)
Base.:-(a::ValueReal, b::Complex) = @invoke -(a, b::Number)
Base.:-(a::ValueReal, b::Complex{Bool}) = @invoke -(a, b::Complex)

Base.:*(a::Complex, b::ValueReal) = @invoke *(a::Number, b)
Base.:*(a::Complex{Bool}, b::ValueReal) = @invoke *(a::Complex, b)
Base.:*(a::ValueReal, b::Complex) = @invoke *(a, b::Number)
Base.:*(a::ValueReal, b::Complex{Bool}) = @invoke *(a, b::Complex)

Base.:/(a::Complex, b::ValueReal) = @invoke /(a::Number, b)
Base.:/(a::ValueReal, b::Complex) = @invoke /(a, b::Number)

Base.:^(a::Union{ValueNumber, ValueReal}, b::Rational) = @invoke ^(a, b::Real)
