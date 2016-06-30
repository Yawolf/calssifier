module qNN

import euclideo

function get_distances(x,matrix)
    mSize = size(matrix,1)
    dists = Array{Tuple{Any,Any}}(mSize)

    for i=1:mSize
        dists[i] = (norm(x[1,:][1:end-1] - matrix[i,:][1:end-1]), matrix[i,end])
    end
    return dists
end

function process_dists(dists, q)
    class = Dict()
    qDist = take(sort!(dists),q)

    for (_,cat) in qDist
        if cat in keys(class)
            class[cat] = class[cat] + 1
        else
            class[cat] = 1
        end
    end
    return reduce((x, y) -> class[x] > class[y] ? x : y, keys(class))
end

function recognize(matrix,q)
    l_class = Array{Any}(1,size(matrix,1))
    for i=1:size(matrix,1)
        dists = get_distances(matrix[i,:]',matrix)
        l_class[i] = process_dists(dists,q)
    end
    return l_class
end

function categorize(matrix,l_class)
    counter = 0
    hit = 0
    rows = size(matrix,1)
    columns = size(matrix,2)-1
    
    for i = 1:rows
        counter += 1
        distance = Inf64
        cat = -Inf
        if matrix[i,end] == l_class[i]
            res = "True"
            hit += 1
        else
            res = "False"
        end
        
        println("Expected: $(matrix[i,end]), Obtained: $(l_class[i]), Result -> $res")
    end
    return (hit/counter) * 100
end

function start(file, q=30)
    matrix = euclideo.get_matrix(file)
    l_class = recognize(matrix,q)
    err = categorize(matrix,l_class)
    println("Precision: $(err)%")
end

end
