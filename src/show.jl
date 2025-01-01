function Base.show(io::IO, ::MIME"text/plain", v::Value)
    print(io, "$(value(v)) ± $(uncertainty(v))")
end

function Base.show(io::IO, v::Value)
    print(io, "$(value(v)) ±ᵤ $(uncertainty(v))")
end
