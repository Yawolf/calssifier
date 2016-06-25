module bagging

import euclideo

function initialize_ss_(matrix, ss, nes)
end

function initialize_ss(matrix, nss, nes)
    ss = Dict()

    for i=1:nss
        ss[i] = zeros(1,size(matrix,2))
    end

    for (c,_) in ss
        ss[c] = matrix[1,:]
        for i=2:nes
            ss[c] = [ss[c] ; matrix[rand(1:size(matrix,1)),:]]
        end
    end
    return ss
end

function separate_by_classes(matrix)
    classes = euclideo.get_classes(matrix)

    c_dict = Dict()
    ptr_matrix = Dict()
    for c in classes
        c_dict[c] = zeros(euclideo.class_number_elements(matrix,c),
                          size(matrix,2) - 1)
        ptr_matrix[c] = 1
    end

    for i=1:size(matrix,1)
        class = matrix[i,:][end]
        c_dict[class][ptr_matrix[class],:] = matrix[i,:][1:end-1]
        ptr_matrix[class] += 1
    end
    return c_dict
end

function calculate_means(class_v)
    means = Dict()
    for (c,v) in class_v
        mean_ = sum(v,1)
        means[c] = mean_ / size(v,1)
    end
    return means
end

function get_ss_average_(v)
    class_v = separate_by_classes(v)
    return calculate_means(class_v)
end

function get_ss_average(ss)
    av_ss = Dict()
    for (c,v) in ss
        av_ss[c] = get_ss_average_(v)
    end
    return av_ss
end

function get_most_repeated_cat(categorized_dict)
    cat = Inf
    max = -Inf

    for (c,v) in categorized_dict
        if v > max
            cat = c
        end
    end
    return cat
end

function categorize_vector(v, ss)
    categorized_dict = Dict()
    
    for (ss,ss_avs) in ss
        min = Inf
        cat = Inf
        for (av, v_av) in ss_avs
            d = norm(v_av - v[1,:][1:end-1]')
            if d < min
                min = d
                cat = av
            end
        end
        if cat in keys(categorized_dict)
            categorized_dict[cat] = categorized_dict[cat] + 1
        else
            categorized_dict[cat] = 1
        end
    end
    return get_most_repeated_cat(categorized_dict)
end

function classify_by_ss(matrix,av_ss)
    hit = 0
    res = "Nothing"
    
    for i=1:size(matrix,1)
        c = categorize_vector(matrix[i,:], av_ss)

        if matrix[i,end] == c
            res = "True"
            hit += 1
        else
            res = "False"
        end
        
        println("Expected: $(matrix[i,end]), Obtained: $(c), Result -> $res")
    end
    return (hit/size(matrix,1)) * 100
end

function start(file,nss=10,nes=0)
    matrix = euclideo.get_matrix(file)

    if nes == 0
        nes = round(size(matrix,1) * 0.1) # 10%
    end

    ss = initialize_ss(matrix, nss, nes)
    av_ss = get_ss_average(ss)
    err = classify_by_ss(matrix,av_ss)
    println("Error: $(err)%")
end

end
