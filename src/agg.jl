function weightedmean(xs)
    isempty(xs) && return convert(eltype(xs), Value(NaN, Inf)*oneunit(eltype(xs)))
    # XXX: using .+ instead of map() fails inference
    agg = mapreduce((a, b) -> map(+, a, b), xs) do x::Value
        w = inv(uncertainty(x))^2
        x * w, w
    end
    return agg[1] / agg[2]
end
