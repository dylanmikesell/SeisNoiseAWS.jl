using Distributed
# To launch workers without blocking the REPL, or the containing function if launching workers programmatically, execute addprocs in its own task.
addprocs()

thisDir = dirname(@__FILE__())
any(path -> path == thisDir, LOAD_PATH) || push!(LOAD_PATH, thisDir)
@everywhere using ModuleA

pmap(testA, 1:10)
