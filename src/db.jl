using Octo.Adapters.PostgreSQL
using GeoInterface: AbstractGeometry
using LibPQ
using LibGEOS

Repo.debug_sql()
conn = Repo.connect(adapter=Octo.Adapters.PostgreSQL,
                    dbname="gis",
                    user="gis",
                    password="gispass")

funcfrom = (pqv::LibPQ.PQValue) -> readwkb(LibPQ.string_view(pqv), hex=true)
functo = (geo::AbstractGeometry) -> writewkb(geo, 4326, hex=true)

LibPQ.register(conn, :geometry, AbstractGeometry, funcfrom, functo)
