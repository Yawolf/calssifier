#!/usr/bin/env julia

module euclideo
using NPZ

function get_matrix(file::AbstractString)
    if file[end-3:end] == ".npy" || file[end-3:end] == ".npz"
        matrix = npzread(file)
    else
        matrix = readcsv(file)
    end
end

get_classes(matrix) = unique(matrix[:,size(matrix,2)])

function separate_matrix(matrix,split)
    if split == (0,0)
        return (matrix,matrix)
    else
        train = matrix[split[1]:split[2],1:end]
        test = matrix[split[2]+1:end, 1:end]
        return (train,test)
    end
end

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

function get_average_dict(classes,len::Int64) 
    fvars = Dict()

    for (_,f) in enumerate(classes)
        fvars[f] = zeros(1,len)
    end
    return fvars
end

function categorize(matrix,classes,average)
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

function split_validation_matrix(matrix,fold)
    m_split = Dict()
    blok = trunc(size(matrix,1) / fold)
    count = 1
    for i=1:blok:size(matrix,1)
        println(count)
        if i + blok < size(matrix,1)
            m_split["D$(count)"] = matrix[i:i+blok-1,1:end]
        else
            m_split["D$(count)"] = matrix[i:end,1:end]
        end
        count += 1
    end
    return m_split
end

function start(f::AbstractString,split=(0,0),m=1)
    matrix = get_matrix(f)
    (train,test) = separate_matrix(matrix,split)
    classes = get_classes(train)
    average = get_average(train,classes)

    if m==1
        ret = categorize(train,classes,average)
    else
        ret = categorize(test,classes,average)
    end
    print("Precision: $(ret)%")
end

function cross_valid(f::AbstractString,split=(0,0),m=1,fold=10)
    matrix = get_matrix(f)
    (train,test) = separate_matrix(matrix,split)
    classes = get_classes(train)
    average = get_average(train,classes)

    if m==1
        mat_in_use = train
    else
        mat_in_use = test
    end

    m_split = split_validation_matrix(mat_in_use,fold)

    lop = []
    for (c,v) in m_split
        ret = categorize(v,classes,average)
        push!(lop,ret)
        println("Precision for $c: $(ret)%")
    end

    println("Mean is: ",mean(lop),"%")
end

end
