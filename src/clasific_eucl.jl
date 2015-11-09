#!/usr/bin/env julia

module euclideo
get_matrix(file::AbstractString) = readcsv(file)

get_classes(matrix) = unique(matrix[:,size(matrix,2)])

class_number_elements(matrix,c) =
                          length(filter((x -> x == c),matrix[:,size(matrix,2)]))

function get_average(matrix,classes)
    columns = size(matrix,2)-1
    rows = size(matrix,1)
    class_position = size(matrix,2)
    av_dict = get_average_dict(classes,columns)

    for i=1:rows
        class = matrix[i,class_position]
        for j=1:columns
            elem = convert(Float64,matrix[i,j])
            if !isnan(elem) || !isdigit(elem)
                av_dict[class][j] =
                    convert(Float64,av_dict[class][j]) + elem
            end
        end
    end
    for c in classes
        av_dict[c] /= convert(Float64,class_number_elements(matrix,c))
    end
    return av_dict
end

function get_average_dict(classes::Array{Any,1},
                          len::Int64) 
    fvars = Dict()

    for (_,f) in enumerate(classes)
        fvars[f] = zeros(1,len)
    end
    return fvars
end

function categorize(matrix::Array{Any,2},
                    classes::Array{Any,1},
                    average::Dict{Any,Any})
    counter = 0
    hit = 0
    rows = size(matrix,1)
    columns = size(matrix,2)-1
    
    for i = 1:rows
        counter += 1
        distance = Inf64
        or_cat = matrix[i,columns+1]
        cat = "nothing"
        
        for c in classes
            new_distance = norm(average[c] - matrix[i,:][1:columns]')
            if new_distance < distance
                distance = new_distance
                cat = c
            end
        end
        if cat == or_cat
            res = "True"
            hit += 1
        else
            res = "False"
        end
        
        println("Expected: $or_cat, Obtained: $cat, Result -> $res")
    end
    return (hit/counter) * 100
end

function start(f::AbstractString)
    matrix = get_matrix(f)
    classes = get_classes(matrix)
    average = get_average(matrix,classes)
    print("Precision: ",categorize(matrix,classes,average),"%")
end
end
