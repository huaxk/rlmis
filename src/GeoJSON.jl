module GeoJSON

export to_feature

GeometryTuple = NamedTuple

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


# "{\"type\":\"Point\", \"coordinates\":[116.39088,39.90763]}"
# {"type": "Feature", "geometry": { "type": "LineString", "coordinates": [ [102.0, 0.0], [103.0, 1.0], [104.0, 0.0], [105.0, 1.0] ] }, "properties": { "prop0": "value0", "prop1": 0.0 } },
# {"type": "Polygon", "coordinates": [[[100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0], [100.0, 0.0]]]}
end  # module GeoJSON
