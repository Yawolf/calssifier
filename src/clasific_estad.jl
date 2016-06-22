module estadistic

using NPZ
import euclideo

function handle_data(file::AbstractString,
                     training)    
    matrix = euclideo.get_matrix(file)
    rows = size(matrix,1)

    if training != (0,0)
        training_matrix = matrix[training[1]:training[2], 1:end]
        testing_matrix = matrix[training[2]+1:end,1:end]
        return (training_matrix,testing_matrix)
    else
        return (matrix,matrix)
    end
end

function separate_by_classes(t_matrix)
    classes = euclideo.get_classes(t_matrix)
    c_dict = Dict()
    
    for c in classes
        c_dict[c] = []
    end
    
    for i=1:size(t_matrix,1)
        push!(c_dict[t_matrix[i,end]],t_matrix[i, 1:end-1])
    end
    return (classes, c_dict)
end

function stdev(elem)
    var = sum((elem-mean(elem)).^2) / (size(elem,2)-1)
    return sqrt(var)
end

function summarize(vector)
    summaries = []
    for i=1:size(vector,1)
        elem = vector[i][1,:]
        push!(summaries,(mean(elem), stdev(elem)))
    end
    return summaries[1:end-1]
end

function summarize_by_classes(matrix)
    (classes,c_dict) = separate_by_classes(matrix)
    summs = Dict()    
    for c in classes
        summs[c] = summarize(c_dict[c])
    end

    return summs
end

function gauss_probability(elem::Float64,
                           mean::Float64,
                           stdev::Float64)
    # math.exp(-(math.pow(x-mean,2)/(2*math.pow(stdev,2))))
    exp = e^(-((elem-mean)^2)/(2*stdev^2))
    return (1/(sqrt(2*pi)*stdev)) * exp
end

function class_probabilities(classes,summaries::Dict{Any,Any},vector)
    prob = Dict()
    for c in classes
        prob[c] = 1
        for i=1:size(summaries[c],2)         
            (mean,stdev) = summaries[c][i]
            x = vector[i]
            prob[c] *= gauss_probability(convert(Float64,x),
                                         convert(Float64,mean),
                                         convert(Float64,stdev))
        end
    end
    return prob
end

function make_predictions(classes,summs,testing_vector)
    probs = class_probabilities(classes,summs,testing_vector)
    class = "Nothing"
    prob = -Inf

    for c in classes
        if class == "Nothing" || prob < probs[c]
            class = c
            prob = probs[c]
        end
    end
    return class
end

function get_predictions(classes,summs::Dict{Any,Any},test_matrix)
    pred = []
    for i=1:size(test_matrix,1)
        push!(pred,make_predictions(classes,summs,test_matrix[i,:][1:end-1]))
    end
    return pred
end

function get_precission(test_matrix,pred)
    hit = 0
    for i=1:size(test_matrix,1)
        endelem = test_matrix[i,:][end]
        prediele = pred[i]
        if endelem == prediele
            hit += 1
            ret = "true"
        else
            ret = "false"
        end
        println("La prediccion: $prediele, el set: $endelem, resultado: $ret")
    end
    return ((hit / size(pred,1)) * 100)
end

end
