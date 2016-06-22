module kmeans
#=
K-MEAN algotrithm:

Step1 -> Given a D set of data and a K number of cluster
         assing K random d element of D set.
Step2 -> Calculate de Centroid for each K centroid
Step3 -> Assign each D data to its closest K centroid
Step4 -> Recalculates new centroids using the new
         Classification
Step5 -> Using the new centorids, classificate again 
         the D set
Step6 -> If there are differences, iterate again, else
         the algorithm is over
Step7 -> Compare the results with the original set
=#
import euclideo
import estadistic
using NPZ

function get_K_vector(matrix,k)
    k_size = size(matrix,1)
    k_dict = Dict()

    for i=1:k
        k_dict[i] = []
    end

    for (c,_) in k_dict
        k_dict[c] = [matrix[rand(1:k_size),:][1:end-1]' for i=1:k]
    end

    return k_dict
            
end

function distribute_vector(vector,k_average)
    d = Inf
    class = -1
    for (c,_) in k_average
        if vector != k_average[c]
            d_ = norm(vector-k_average[c])
            if d_ < d
                d = d_
                class = c
            end
        end
    end
    return class
end

function distribute_by_classes(matrix,k_average)
    dbclass = Dict()
    
    for (c,_) in k_average
        dbclass[c] = []
    end

    for i=1:size(matrix,1)
        vector = matrix[i,:][1:end-1]'
        class = distribute_vector(vector,k_average)
        push!(dbclass[class],vector)
    end
    return dbclass
end

function get_average_by_classes(dbclass)
    new_class_mean = Dict()

    for (c,v) in dbclass
        mean = foldl(+,0,v)

        if length(v) == 0
            new_class_mean[c] = mean / 1
        else
            new_class_mean[c] = mean / size(v,1)
        end
    end
    return new_class_mean       
end

function does_this_function_converge(k_average,average)
    hack = Int64[]

    for i=1:length(k_average)
        if k_average[i] != average[i]
            push!(hack,1)
        else
            push!(hack,0)
        end
    end

    if sum(hack) == 0
        return true
    else
        return false
    end
end

function categorize(matrix,matrix_f,equiv)
    counter = 0
    hit = 0
    rows = size(matrix,1)
    columns = size(matrix,2)-1
    
    for i = 1:rows
        counter += 1
        distance = Inf64
        cat = "nothing"
        
        if equiv[matrix_f[i,end]] == matrix[i,end]
            res = "True"
            hit += 1
        else
            res = "False"
        end
        
        println("Expected: $(matrix[i,end]), Obtained: $(equiv[matrix_f[i,end]]), Result -> $res")
    end
    return (hit/counter) * 100
end

function categorize_with_new_av(matrix,k_average)
    n_mat = zeros(size(matrix))
    new_cat = Inf
    for i=1:size(matrix,1)
        distance = Inf
        for (c,_) in k_average
            new_distance = norm(k_average[c] - matrix[i,:][1:end-1]')
            if new_distance < distance
                distance = new_distance
                new_cat = c
            end
        end
        n_mat[i,:] = [matrix[i,:][1:end-1]' new_cat]
    end
    return n_mat
end

function replace_matrix_cat(f_matrix,equiv)
    ret = Array(Any,size(f_matrix))
    for i=1:size(f_matrix,1)
        ret[i,:] = f_matrix[i,:]
        ret[i,end] = equiv[f_matrix[i,end]]
    end
    return ret
end

function write_matrix_on_file(f_matrix,file)
    bname = replace(file,basename(file),"kmeans.$(basename(file))")
    if file[end-3:end] == ".npy" || file[end-3:end] == ".npz"
        bname = replace(bname,".npy",".data")
        writedlm("$(bname)",f_matrix,",")
    else
        writedlm("$(bname)",f_matrix,",")
    end
    println("Matrix saved in: $(bname)")
end

function saving_matrix(f_matrix,equiv,file)
    write_matrix_on_file(replace_matrix_cat(f_matrix,equiv),file)
end

function start(file,k = 4) # Step 0, set K number
    matrix = euclideo.get_matrix(file)  # Step 0, load D set
    k_dict = get_K_vector(matrix,k) # Step 1, K random elemnts, clusters
    k_average = get_average_by_classes(k_dict) # Step 2, average for each K
    matrix_class = categorize_with_new_av(matrix,k_average) # Step 3, classify
    f_matrix = iteration(matrix_class,k_average,k) # Lets iterate
    equiv = classes_equivalence(matrix,f_matrix)
    err = categorize(matrix,f_matrix,equiv) # Step 7, compare results
    saving_matrix(f_matrix,equiv,file)
    print("Precision: $(err)%")
end

function iteration(matrix_class,k_average,k)
    by_classes = distribute_by_classes(matrix_class,k_average) # Step 4, split by classes
    average = get_average_by_classes(by_classes) # Step 4, And get average using new classes

    if does_this_function_converge(k_average,average) # Do converge?
        return matrix_class # Return the value
    else
        return iteration(categorize_with_new_av(matrix_class,average),average,k)
    end
end

function classes_equivalence(matrix,f_matrix)
    (classes_orig,dict_orig) = estadistic.separate_by_classes(matrix)
    (classes_f,dict_f) = estadistic.separate_by_classes(f_matrix)
    equiv = Dict()
    
    for (c,v) in dict_f
        equiv[c] = get_equivalence(dict_orig, v)
    end
    
    return equiv
end

function get_equivalence(dict, v)
    cat_equiv = Inf
    matches = -Inf
    
    for (k,val) in dict
        n_matches = 0
        for elem in v
            if elem in val
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

end
