using ArchGDAL
const AG = ArchGDAL

province_name = "Jiangsu"

provinces = AG.registerdrivers() do
    AG.read("D:/sources/data/region_shp/CHN_adm1.shp") do dataset
        layer = AG.getlayer(dataset, 0)
        # [
        #     (name1=AG.getfield(ft, "NAME_1"), geom=AG.getgeom(ft))
        #     for ft in layer
        #     if AG.getfield(ft, "NAME_1")==province_name
        # ]
        AG.getfeature(layer, 0) do ft
            n = AG.nfield(ft)
            for i in 0:n-1
                fd = AG.getfielddefn(ft, i)
                type = AG.gettype(fd)
                type_to = AG._FIELDTYPE[type]
                println(AG.getname(fd), " <==> ", type_to)
            end
            n = AG.ngeomfield(ft)
            for i in 0:n-1
                gf = AG.getgeomfield(ft, i)
                typename = AG.getgeomname(gf)
                @show typename
            end
        end
        set = Set()
        for ft in layer
            geom = AG.getgeom(ft)
            typename = AG.getgeomname(geom)
            push!(set, typename)
        end
        @show set
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
