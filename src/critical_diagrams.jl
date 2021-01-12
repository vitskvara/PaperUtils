using Distributions

# R = mean ranks, n = number of datasets, k = number of models
friedman_test_statistic(R::Vector,n::Int,k::Int) = 12*n/(k*(k+1))*(sum(R.^2) - k*(k+1)^2/4)
# k = number of models
crit_chisq(α::Real, df::Int) = quantile(Chisq(df), 1-α)
friedman_critval(α::Real, k::Int) = crit_chisq(α/2, k-1)


# k = number of groups, df = (N - k) = (total samples - k)
crit_srd(α::Real, k::Real, df::Real) = 
    (isnan(k) | isnan(df)) ? NaN : quantile(StudentizedRange(df, k), 1-α)
nemenyi_cd(k::Int, n::Int, α::Real) = sqrt(k*(k+1)/(6*n))*crit_srd(α, k, Inf)/sqrt(2)


function ranks2tikzcd(ranks, algnames, c, caption = ""; label = "", pos = "h")
    n = length(ranks)
    @assert n == length(algnames)
    ranks = reshape(ranks, n)
    for i in 1:length(ranks)
        ranks[i] = Float64(parse(ranks[i]))
    end

    # header
    s = "\\begin{figure}[$pos] \n \\center \n \\begin{tikzpicture} \n"
    s = wspad(s, 2)
    #axis
    s = string(s, drawaxis(ranks))
    # nodes
    s = string(s, drawnodes(ranks, algnames))
    # levels
    s = string(s, drawlevels(ranks, c))
    # end of figure
    s = wspad(s, 1)
    s = string(s, "\\end{tikzpicture} \n")
    if caption!=""
        s = string(s, " \\caption{$caption} \n")
    end
    if label!=""
        s = string(s, " \\label{$label} \n")
    end
    s = string(s, "\\end{figure}")

    return s
end

function drawaxis(ranks)
    mx = ceil(maximum(ranks))
    mn = floor(minimum(ranks))

    s = "\\draw ($(mn),0) -- ($(mx),0); \n"
    s = wspad(s, 2)
    s = string(s, "\\foreach \\x in {$(Int(mn)),...,$(Int(mx))} \\draw (\\x,0.10) -- (\\x,-0.10) node[anchor=north]{\$\\x\$}; \n")
    return s
end

function drawnodes(ranks, algnames)
    isort = sortperm(ranks)
    ranks = ranks[isort]
    algnames = algnames[isort]

    mx = ceil(ranks[end])
    mn = floor(ranks[1])
    nor = length(ranks) # number of ranks
    nos = Int(ceil(nor/2)) # number of ranks on one side (start with left, there may be one more if nor is odd)

    s = ""
    for (i, r) in enumerate(ranks)
        s = wspad(s,2)
        if i<=nos
            s = string(s, "\\draw ($(r),0) -- ($r,$(i*0.3-0.1)) -- ($(mn-0.1), $(i*0.3-0.1)) node[anchor=east] {$(algnames[i])}; \n")
        else
            s = string(s, "\\draw ($(r),0) -- ($r,$((nor-i)*0.3+0.2)) -- ($(mx+0.1), $((nor-i)*0.3+0.2)) node[anchor=west] {$(algnames[i])}; \n")
        end
    end

    return s
end

function drawlevels(ranks, cv)
    ranks = sort(ranks)

    mx = ceil(ranks[end])
    mn = floor(ranks[1])
    nor = length(ranks) # number of ranks

    # generate levels
    levels = []
    for (i,r) in enumerate(ranks)
        if i == nor
            break
        elseif ranks[i+1] - r <= cv
            push!(levels, [r, ranks[i+1], 0.05])
        end
    end

    # now differentiate them if they should not be at the same heigth
    i = 1
    while i <= length(levels)
        if i == length(levels)
            break
        elseif abs(levels[i][1] - levels[i+1][2]) < cv
            levels[i][2] = levels[i+1][2]
            splice!(levels, i+1)
        else
            i += 1
        end
    end

    for (i,level) in enumerate(levels)
        if i == length(levels)
            break
        elseif abs(level[2] - levels[i+1][1])<0.08 && abs(level[1] - levels[i+1][2]) > cv && level[3] == levels[i+1][3]
            levels[i+1][3] = level[3] + 0.1
        end
    end

    # draw them
    s = ""
    for level in levels
        s = wspad(s,2)
        s = string(s, "\\draw[line width=0.06cm,color=black,draw opacity=1.0] ($(level[1]-0.03),$(level[3])) -- ($(level[2]+0.03),$(level[3])); \n")
    end
#    println(levels)
    return s
end
