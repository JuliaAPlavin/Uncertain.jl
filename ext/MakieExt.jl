module MakieExt

using Makie
using Makie.IntervalSets
import Makie: convert_arguments
using Uncertain
using Uncertain.Accessors


convert_arguments(ct::PointBased, X::AbstractVector{<:Tuple{<:Any,<:U.Value}}) = convert_arguments(ct, @modify(U.value, X[∗][∗]))
convert_arguments(ct::PointBased, X::AbstractVector{<:Tuple{<:Real,<:U.ValueReal}}) = convert_arguments(ct, @modify(U.value, X[∗][∗]))  # disambiguation
convert_arguments(ct::PointBased, X::AbstractVector{<:Point2{<:U.Value}}) = convert_arguments(ct, @modify(U.value, X[∗][∗]))
convert_arguments(ct::Type{<:Union{Errorbars,Rangebars,Band}}, X::AbstractVector{<:Tuple{<:Any,<:U.Value}}) = convert_arguments(ct, first.(X), last.(X))

convert_arguments(ct::PointBased, x::AbstractVector, y::AbstractVector{<:U.Value}) = convert_arguments(ct, x, U.value.(y))
convert_arguments(ct::PointBased, x::AbstractVector{<:Real}, y::AbstractVector{<:U.ValueReal}) = convert_arguments(ct, x, U.value.(y))  # disambiguation
convert_arguments(ct::PointBased, x::AbstractVector{<:U.Value}, y::AbstractVector) = convert_arguments(ct, U.value.(x), y)
convert_arguments(ct::PointBased, x::AbstractVector{<:U.ValueReal}, y::AbstractVector{<:Real}) = convert_arguments(ct, U.value.(x), y)  # disambiguation
convert_arguments(ct::PointBased, x::AbstractVector{<:U.Value}, y::AbstractVector{<:U.Value}) = convert_arguments(ct, U.value.(x), U.value.(y))  # disambiguation
convert_arguments(ct::PointBased, x::AbstractVector{<:U.ValueReal}, y::AbstractVector{<:U.ValueReal}) = convert_arguments(ct, U.value.(x), U.value.(y))  # disambiguation

convert_arguments(ct::Type{<:Union{Rangebars,Band}}, x::AbstractVector, y::AbstractVector{<:U.Value}) = convert_arguments(ct, x, Interval.(y))
convert_arguments(ct::Type{<:Union{Rangebars,Band}}, x::AbstractVector{<:U.Value}, y::AbstractVector{<:U.Value}) = convert_arguments(ct, U.value.(x), Interval.(y))

convert_arguments(ct::Type{<:Errorbars}, x::AbstractVector, y::AbstractVector{<:U.Value}) = convert_arguments(ct, x, U.value.(y), U.uncertainty.(y))
convert_arguments(ct::Type{<:Errorbars}, x::AbstractVector{<:U.Value}, y::AbstractVector) = convert_arguments(ct, U.value.(x), y)
convert_arguments(ct::Type{<:Errorbars}, x::AbstractVector{<:U.Value}, y::AbstractVector{<:U.Value}) = convert_arguments(ct, U.value.(x), U.value.(y), U.uncertainty.(y))

convert_arguments(ct::Type{<:Union{HLines,VLines}}, x::AbstractVector{<:U.Value}) = convert_arguments(ct, U.value.(x))

end
