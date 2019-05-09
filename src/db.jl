using Octo.Adapters.PostgreSQL
using GeoInterface

include("LibPQEx.jl")
using .LibPQEx

Repo.debug_sql()
conn = Repo.connect(adapter=Octo.Adapters.PostgreSQL,
                    dbname="gis",
                    user="gis",
                    password="gispass")
register_type(conn, :geometry, AbstractGeometry)
