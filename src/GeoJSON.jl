
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
