using Octo.Adapters.PostgreSQL
using LibPQ: PQValue
using GeoInterface: AbstractGeometry
using LibGEOS

include("LibPQEx.jl")
using .LibPQEx

Repo.debug_sql()
conn = Repo.connect(adapter=Octo.Adapters.PostgreSQL,
                    dbname="gis",
                    user="gis",
                    password="gispass")

funcfrom = (pqv::PQValue) -> (hexwkb = LibPQ.string_view(pqv); readwkb(hexwkb, hex=true))
functo = (geo::AbstractGeometry) -> writewkb(geo, 4326, hex=true)

LibPQEx.register(conn,
                :geometry,
                AbstractGeometry,
                funcfrom,
                functo)
