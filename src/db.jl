using Octo.Adapters.PostgreSQL
using GeoInterface: AbstractGeometry
using LibPQ
using LibGEOS

include("exts/LibPQEx.jl")

Repo.debug_sql()
conn = Repo.connect(adapter=Octo.Adapters.PostgreSQL,
                    dbname="gis",
                    user="gis",
                    password="gispass")

# funcfrom(pqv::LibPQ.PQValue) = readwkb(LibPQ.string_view(pqv), hex=true)
# functo(geo::AbstractGeometry) = writewkb(geo, hex=true)
# funcfrom(pqv::LibPQ.PQValue) = GeoWKB.fromEWKB(hex2bytes(LibPQ.string_view(pqv)))
# functo(geo::AbstractGeometry) = bytes2hex(GeoWKB.toEWKB(geo))
#
# register(conn, :geometry, AbstractGeometry, funcfrom, functo)

LibPQEx.register(conn, :ArchGDAL)
