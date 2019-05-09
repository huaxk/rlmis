using Octo.Adapters.PostgreSQL
using LibPQ: PQValue
using GeoInterface: AbstractGeometry

include("LibPQEx.jl")
using .LibPQEx

Repo.debug_sql()
conn = Repo.connect(adapter=Octo.Adapters.PostgreSQL,
                    dbname="gis",
                    user="gis",
                    password="gispass")

# register geometry type
type, oid = getTypeOid(conn, "geometry")
registerType(type, oid, AbstractGeometry)

function Base.parse(::Type{AbstractGeometry}, pqv::PQValue{:($oid)})
    hexwkb = LibPQ.string_view(pqv)
    readwkb(hexwkb, hex=true)
end
