using Octo.Adapters.PostgreSQL

Repo.debug_sql()
Repo.connect(
    adapter=Octo.Adapters.PostgreSQL,
    dbname="gis",
    user="gis",
    password="gispass"
)

include("controllers.jl")

Bukdu.start(8080)
Base.JLOptions().isinteractive==0 && wait()
