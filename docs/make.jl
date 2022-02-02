using InflationFunctions
using Documenter

DocMeta.setdocmeta!(InflationFunctions, :DocTestSetup, :(using InflationFunctions); recursive=true)

makedocs(;
    modules=[InflationFunctions],
    authors="Rodrigo Chang <rrcp777@gmail.com> and contributors",
    repo="https://github.com/DIE-BG/InflationFunctions.jl/blob/{commit}{path}#{line}",
    sitename="InflationFunctions.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://DIE-BG.github.io/InflationFunctions.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/DIE-BG/InflationFunctions.jl",
    devbranch="main",
)
