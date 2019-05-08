include("db.jl")
include("controllers.jl")

Bukdu.start(8080)
Base.JLOptions().isinteractive==0 && wait()
