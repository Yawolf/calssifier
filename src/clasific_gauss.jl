import estadistic
import euclideo

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

function cov_by_class(c_dict)
    cov_dict = Dict()
    for (c,v) in c_dict
        cov_dict[c] = cov(v)
    end
    return cov_dict
end

function mean_by_columns(c_dict)
    mean_dict = Dict()
    for c in keys(c_dict)
        mean_dict[c] = []
    end

    for (c,m) in c_dict
        for i=1:size(m,2)
            push!(mean_dict[c],mean(m[:,i]))
        end
    end
    return mean_dict
end

function get_probability(input,mean_,cova)
    var = input - mean_
    exponent_ = (((1/2)*(var)') * inv(cova) * var)[1]
    exponent = e^-exponent_
    division = 1/(((2*pi)^(size(input,2)/2)) * (det(cova)^(1/2)))
    return division * exponent
end

function classify(dataset,c_dict,mean_dict,cov_dict)
    hit = 0
    ret = "true"
    for i=1:size(dataset,1)
        elem = dataset[i,:][1:end-1]
        bestprob = -Inf
        class = "None"
        for (c,v) in c_dict
            prob = get_probability(elem,mean_dict[c],cov_dict[c])
            if prob > bestprob
                bestprob = prob
                class = c
            end
        end
        
        orClass = dataset[i,:][end]
        if orClass == class
            ret = "true"
            hit += 1
        else
            ret = "false"
        end

        println("Expected: $orClass, Obtained: $class, result -> $ret")
    end
    return (hit/size(dataset,1))*100
end
    
function start(file,train=0.1)
    (train,test) = estadistic.handle_data(file,train)
    c_dict = separate_by_classes(train)
    cov_dict = cov_by_class(c_dict)
    mean_dict = mean_by_columns(c_dict)
    prec = classify(test,c_dict,mean_dict,cov_dict)

    println("Precission: $(prec)%")
end
