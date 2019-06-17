using JSON2
using GeoInterface
using GeoInterface: AbstractGeometry
using GeoJSON
using LibGEOS
using ArchGDAL

GeometryTuple = NamedTuple

"""
    (type="Point", coordinates=[12.0, 45.0])
"""
function tuple2geo(tp::NamedTuple)
    t = Symbol(tp.type)
    # convert(Val(t), tp)
    type = @eval LibGEOS.$t
    convert(type, tp)
end

for geom in (:Point, :MultiPoint, :LineString, :MultiLineString, :Polygon, :MultiPolygon)
    @eval Base.convert(::Type{LibGEOS.$geom}, tp::NamedTuple) = LibGEOS.$geom(tp.coordinates)
end

# Base.convert(::Val{:Point}, tp::NamedTuple) = GeoInterface.Point(tp.coordinates)
# Base.convert(::Val{:MultiPoint}, tp::NamedTuple) = GeoInterface.MultiPoint(tp.coordinates)
# Base.convert(::Val{:LineString}, tp::NamedTuple) = GeoInterface.LineString(tp.coordinates)
# Base.convert(::Val{:MultiLineString}, tp::NamedTuple) = GeoInterface.MultiLineString(tp.coordinates)
# Base.convert(::Val{:Polygon}, tp::NamedTuple) = GeoInterface.Polygon(tp.coordinates)
# Base.convert(::Val{:MultiPolygon}, tp::NamedTuple) = GeoInterface.MultiPolygon(tp.coordinates)
# Base.convert(::Val{:GeometryCollection}, tp::NamedTuple) = GeoInterface.GeometryCollection(tuple2geo.(tp.geometries))
# Base.convert(::Val{:Feature}, tp::NamedTuple) = begin
#     feature = GeoInterface.Feature(tuple2geo(tp.geometry), tp.properties)
#     ks = keys(tp)
#     :id in ks && (feature.properties["featureid"] = tp.id)
#     :bbox in ks && (feature.properties["bbox"] = GeoInterface.BBox(tp.bbox))
#     :crs in ks && (feature.properties["crs"] = tp.crs)
#     feature
# end
# Base.convert(::Val{:FeatureCollection}, tp::NamedTuple) = begin
#     features = GeoInterface.Feature[tuple2geo.(tp.features)...]
#     featurecollection = GeoInterface.FeatureCollection(features)
#     ks = keys(tp)
#     :bbox in ks && (featurecollection.bbox = GeoInterface.BBox(tp.bbox))
#     :crs in ks && (featurecollection.crs = tp.crs)
#     featurecollection
# end

# JSON2.write(io::IO, obj::T; kwargs...) where {T <: AbstractGeometry} = begin
#     geodict = GeoJSON.geo2dict(obj)
#     JSON2.write(io, geodict; kwargs...)
# end

JSON2.write(io::IO, obj::T; kwargs...) where {T <: ArchGDAL.IGeometry} = begin
    json = ArchGDAL.toJSON(obj)
    Base.write(io, json)
    return
end

function JSON2.write(io::IO, obj::AbstractString; kwargs...)
    if startswith(obj, "{\"type\":") || startswith(obj, "{\"coordinates\":")
        Base.write(io, obj)
    else
        Base.write(io, '"')
        if JSON2.needescape(obj)
            bytes = codeunits(obj)
            for i = 1:length(bytes)
                @inbounds b = JSON2.ESCAPECHARS[bytes[i] + 0x01]
                Base.write(io, b)
            end
        else
            Base.write(io, obj)
        end
        Base.write(io, '"')
    end
    return
end

function to_feature(data::GeometryTuple, geofield::Symbol) # where {T <: NamedTuple{names, types}} where {names, types}
    propertykeys = [k for k in keys(data) if k != geofield]
    propertyvals = [data[:($k)] for k in keys(data) if k != geofield]
    properties = NamedTuple{Tuple(propertykeys)}(Tuple(propertyvals))
    NamedTuple{(:type, :geometry, :properties)}(("Feature", data[geofield], properties))
end

function to_features(data::Array{T}, geofield::Symbol) where {T <: NamedTuple}
    [to_feature(nt, geofield) for nt in data]
end

function to_featurecollection(data::Array{T}, geofield::Symbol) where {T <: NamedTuple}
    NamedTuple{(:type, :features)}(("FeatureCollection", to_features(data, geofield)))
end
