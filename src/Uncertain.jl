module Uncertain

export U, ±ᵤ

using Accessors

include("types.jl")
include("show.jl")
include("maths.jl")
include("agg.jl")
include("disambiguation.jl")

±ᵤ(v, e) = Value(v, e)

Base.promote_rule(::Type{<:ValueNumber{TM,SM}}, ::Type{T}) where {T<:Number,TM,SM} = ValueNumber{promote_type(T, TM), promote_type(real(T), SM)}
Base.promote_rule(::Type{T2}, ::Type{Complex{T1}}) where {T1,TM,SM,T2<:ValueNumber{TM,SM}} = Complex{real(promote_type(T1, T2))}
Base.promote_rule(::Type{<:ValueReal{TM,SM}}, ::Type{T}) where {T<:Real,TM,SM} = ValueReal{promote_type(T, TM), promote_type(real(T), SM)}
Base.promote_rule(::Type{<:ValueReal{T1,S1}}, ::Type{<:ValueReal{T2,S2}}) where {T1,T2,S1,S2} = ValueReal{promote_type(T1, T2), promote_type(S1, S2)}
Base.promote_rule(::Type{<:ValueNumber{T1,S1}}, ::Type{<:ValueNumber{T2,S2}}) where {T1,T2,S1,S2} = ValueNumber{promote_type(T1, T2), promote_type(S1, S2)}
Base.promote_rule(::Type{<:ValueReal{T1,S1}}, ::Type{<:ValueNumber{T2,S2}}) where {T1,T2,S1,S2} = ValueNumber{promote_type(T1, T2), promote_type(S1, S2)}
Base.promote_rule(::Type{<:ValueNumber{T2,S2}}, ::Type{<:ValueReal{T1,S1}}) where {T1,T2,S1,S2} = ValueNumber{promote_type(T1, T2), promote_type(S1, S2)}
Base.promote_rule(::Type{<:ValueAny{T1,S1}}, ::Type{<:ValueAny{T2,S2}}) where {T1,T2,S1,S2} = ValueAny{promote_type(T1, T2), promote_type(S1, S2)}


baremodule U
export Value, ValueAny, ValueNumber, ValueReal, value, uncertainty, weightedmean
using ..Uncertain:
    Value, ValueAny, ValueNumber, ValueReal,
    value, uncertainty,
    weightedmean
end


end
