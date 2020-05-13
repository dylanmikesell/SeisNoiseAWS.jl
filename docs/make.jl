using Documenter, SeisNoiseAWS

makedocs(;
    modules=[SeisNoiseAWS],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/dylanmikesell/SeisNoiseAWS.jl/blob/{commit}{path}#L{line}",
    sitename="SeisNoiseAWS.jl",
    authors="Dylan Mikesell, Boise State University",
    assets=String[],
)

deploydocs(;
    repo="github.com/dylanmikesell/SeisNoiseAWS.jl",
)
