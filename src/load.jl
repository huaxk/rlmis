using ArchGDAL
using GDAL
const AG = ArchGDAL

province_name = "Jiangsu"

provinces = AG.registerdrivers() do
    AG.read("D:/sources/data/region_shp/CHN_adm1.shp") do dataset
        layer = AG.getlayer(dataset, 0)
        [
            (name1=AG.getfield(ft, "NAME_1"), geom=AG.getgeom(ft))
            for ft in layer
            if AG.getfield(ft, "NAME_1")==province_name
        ]
    end
end

cities = AG.registerdrivers() do
    AG.read("D:/sources/data/region_shp/CHN_adm2.shp") do dataset
        layer = AG.getlayer(dataset, 0)
        [
            (
                name1=AG.getfield(ft, "NAME_1"),
                name2=AG.getfield(ft, "NAME_2"),
                geom=AG.getgeom(ft)
            )
            for ft in layer
            if AG.getfield(ft, "NAME_1")==province_name
        ]
    end
end

countries = AG.registerdrivers() do
    AG.read("D:/sources/data/region_shp/CHN_adm3.shp") do dataset
        layer = AG.getlayer(dataset, 0)
        [
            (
                name1=AG.getfield(ft, "NAME_1"),
                name2=AG.getfield(ft, "NAME_2"),
                name3=AG.getfield(ft, "NAME_3"),
                geom=AG.getgeom(ft)
            )
            for ft in layer
            if AG.getfield(ft, "NAME_1")==province_name
        ]
    end
end
