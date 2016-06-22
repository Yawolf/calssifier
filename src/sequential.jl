module sequential

import estadistic
import euclideo
import kmeans
using NPZ

function init_cm_mat(matrix)
    ck = Dict()
    
    ck[1] = [matrix[1,:] 1]
    ck[1][1,end-1] = 1
    iterable_matrix = matrix[2:size(matrix,1),:]
    return (ck,iterable_matrix)
end

function update_means(vectors)
    mean_ = sum(vectors[:, 1:end .!= end],1)

    if length(vectors) == 0
        mean = mean_ / 1
    else
        mean = mean_ / size(vectors,1)
    end
    return mean
end

function iteration_(ck,iterable_matrix,th,q)
    index = 2
    means = Dict()
    means[1] = ck[1] # mean
    ck_ = ck
    q_ = q - 1
    
    for i=1:size(iterable_matrix,1)
        min = Inf
        cat = -Inf
        for (c,v) in ck_
            val = norm(v[1,:][1:end-2]' - iterable_matrix[i,:][1:end-1]')
            if val < min
                min = val
                cat = c
            end
        end
        if min > th && q_ > 0
            ck_[index] = [iterable_matrix[i,:][1:end-1]' index i+1]
            means[index] = ck_[index]
            index = index + 1
            q_ = q_ - 1
        else
            ck_[cat] = [ck_[cat]; [iterable_matrix[i,:][1:end-1]' cat i+1]]
            means[cat] = update_means(means[cat])
        end
    end
    return ck_
end

function iteration(matrix,th,q)
    (ck, iterable_matrix) = init_cm_mat(matrix)
    return (ck,iteration_(ck,iterable_matrix,th,q))
end

function size_of_matrix(f_matrix)
    col = size(f_matrix[1],2) - 1
    rows = 0
    for (_,v) in f_matrix
        rows = rows + size(v, 1)
    end
    return (rows,col)
end

function save_matrix(f_matrix,file)
    bname = replace(file,basename(file),"seq.$(basename(file))")
    saving_matrix = zeros(size_of_matrix(f_matrix))
    it = 0
    for (c,_) in f_matrix
        for i=1:size(f_matrix[c],1)
            saving_matrix[f_matrix[c][i,end],:] = f_matrix[c][i,:][1:end-1]
        end
    end
    if file[end-3:end] == ".npy" || file[end-3:end] == ".npz"
        npzwrite("$(bname)",saving_matrix)
    else
        writedlm("$(bname)",saving_matrix,",")
    end
end

function classes_equivalence(matrix,f_matrix)
    (classes_orig,dict_orig) = estadistic.separate_by_classes(matrix)
    equiv = Dict()
    
    for (c,_) in f_matrix
        equiv[c] = get_equivalence(dict_orig, f_matrix[c])
    end
    
    return equiv
end

function get_equivalence(dict, v)
    cat_equiv = Inf
    matches = -Inf
    
    for (k,val) in dict
        n_matches = 0
        for i=1:size(v,1)
            if v[i,:][1:end-2]' in val
                n_matches = n_matches + 1
            end
        end
        if n_matches > matches
            matches = n_matches
            cat_equiv = k
        end
    end
    return cat_equiv
end

function categorize(matrix,file,equiv)
    bname = replace(file,basename(file),"seq.$(basename(file))")
    f_matrix = euclideo.get_matrix(bname)

    counter = 0
    hit = 0
    rows = size(matrix,1)
    columns = size(matrix,2)-1
    
    for i = 1:rows
        counter += 1
        distance = Inf64
        cat = "nothing"
        if equiv[f_matrix[i,end]] == matrix[i,end]
            res = "True"
            hit += 1
        else
            res = "False"
        end
        
        println("Expected: $(matrix[i,end]), Obtained: $(equiv[f_matrix[i,end]]), Result -> $res")
    end
    return (hit/counter) * 100
end

function start(file,th=3,q=4)
    matrix = euclideo.get_matrix(file)
    (ck,f_matrix) = iteration(matrix,th,q)
    save_matrix(f_matrix,file)
    equiv = classes_equivalence(matrix,f_matrix)
    err = categorize(matrix,file,equiv)
    print("Precision: $(err)%")
end

end
