@testitem "Makie" begin
    using Makie

    scatter([1,2], [1±ᵤ0.1, 2±ᵤ0.3])
    scatter([1±ᵤ1, 2±ᵤ2], [1±ᵤ0.1, 2±ᵤ0.3])
    scatter([1±ᵤ1, 2±ᵤ2], [1, 2])
    rangebars([1,2], [1±ᵤ0.1, 2±ᵤ0.3])
    rangebars([1±ᵤ1, 2±ᵤ2], [1±ᵤ0.1, 2±ᵤ0.3])
    errorbars([1,2], [1±ᵤ0.1, 2±ᵤ0.3])
    errorbars([1±ᵤ1, 2±ᵤ2], [1±ᵤ0.1, 2±ᵤ0.3])
    band([1,2], [1±ᵤ0.1, 2±ᵤ0.3])
    band([1±ᵤ1, 2±ᵤ2], [1±ᵤ0.1, 2±ᵤ0.3])

    scatter([(1,1±ᵤ0.1), (2,2±ᵤ0.3)])
    scatter([(1±ᵤ1,1±ᵤ0.1), (2±ᵤ2,2±ᵤ0.3)])
    scatter([Point2(1±ᵤ0.1,1±ᵤ0.1), Point2(2±ᵤ0.3,2±ᵤ0.3)])
    rangebars([(1,1±ᵤ0.1), (2,2±ᵤ0.3)])
    rangebars([(1±ᵤ1,1±ᵤ0.1), (2±ᵤ2,2±ᵤ0.3)])
    errorbars([(1,1±ᵤ0.1), (2,2±ᵤ0.3)])
    errorbars([(1±ᵤ1,1±ᵤ0.1), (2±ᵤ2,2±ᵤ0.3)])
    band([(1,1±ᵤ0.1), (2,2±ᵤ0.3)])
    band([(1±ᵤ1,1±ᵤ0.1), (2±ᵤ2,2±ᵤ0.3)])

    hlines([1±ᵤ0.1, 2±ᵤ0.3])
    vlines([1±ᵤ0.1, 2±ᵤ0.3])
    hlines(1±ᵤ0.1)
    vlines(1±ᵤ0.1)

    hspan([1±ᵤ0.1, 2±ᵤ0.3])
    vspan([1±ᵤ0.1, 2±ᵤ0.3])
    hspan(1±ᵤ0.1)
    vspan(1±ᵤ0.1)
end

@testitem "mcm makie" begin
    using Makie
    using MonteCarloMeasurements
    using MonteCarloMeasurements.StaticArrays
    # smoke tests only for now

    p = Particles([1,2,3])
    hist(p)
    stephist(p)
    
    scatter([p], [p])
    scatter([1], [p])
    scatter([p], [1])

    band([1], [p])
    band([p], [p])

    scatter([(p, p)])
    scatter([(1, p)])
    scatter([(p, 1)])
    scatter([SVector(p, p)])
    band([(1, p)])
    band([(p, p)])
    band([SVector(p, p)])
end
