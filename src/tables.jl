
"""
    eol(s)

Replaces the "& " at the end of s with a tabular end of line.
"""
function eol(s)
    return string(s[1:end-2], " \\\\ \n")
end

"""
    wspad(s, n)

Pads s with n white spaces.
"""
function wspad(s, n)
    return string(s, repeat(" ", n))
end

"""
    df2tex(df, caption="", pos = "h", align = "c";
           fitcolumn = false, lasthline = false)

Convert DataFrame to a LaTex table.
"""
function df2tex(df, caption=""; label = "", pos = "h", align = "c",
    fitcolumn = false, lasthline = false, firstvline = false)
    cnames = names(df)
    nrows, ncols = size(df)

    # create the table beginning
    if fitcolumn
        s = "\\begin{table} \n \\center \n \\resizebox{\\columnwidth}{!}{ \n \\begin{tabular}[$pos]{"
    else
        s = "\\begin{table} \n \\center \n \\begin{tabular}[$pos]{"
    end
    for n in 1:ncols
        if firstvline && n == 1
            s = string(s, "$align | ")
        else
            s = string(s, "$align ")
        end
    end
    s = string(s,"} \n")

    # create the header
    s = wspad(s,2)
    for name in names(df)
        s = string(s, "$name & ")
    end
    s = eol(s)
    s = wspad(s,2)
    s = string(s, "\\hline \n")

    # fill the table
    for i in 1:nrows
        s = wspad(s,2)
        for j in 1:ncols
            s = string(s, "$(df[i,j]) & ")
        end
        s= eol(s)
        if lasthline && i == nrows-1
            s = wspad(s,2)
            s = string(s, "\\hline\n")
        end
    end

    # create the table ending
    s = string(s, " \\end{tabular}\n")
    if fitcolumn
        s = string(s, " }\n")
    end
    if caption!=""
        s = string(s, " \\caption{$caption} \n")
    end
    if label!=""
        s = string(s, " \\label{$label} \n")
    end
    s = string(s, "\\end{table}")

    return s
end

"""
    string2file(f, s)

Save string s to file f.
"""
function string2file(f, s)
    open(f, "w") do _f
        write(_f, s)
    end
end

"""
    miss2hyphen!(df)

Replaces all missing values with a hyphen "--".
"""
function miss2hyphen!(df)
    nrows, ncols = size(df)

    for i in 1:nrows
        for j in 1:ncols
            if ismissing(df[i,j])
             df[i,j]="--"
            end
        end
    end

    return df
end

"""
    miss2hyphen(df)

Replaces all missing values with a hyphen "--".
"""
function miss2hyphen(df)
    _df = deepcopy(df)
    return miss2hyphen!(df)
end

"""
    rpaddf!(df,n)

Rightpad all numerical values with zeros to have n decimal digits.
"""
function rpaddf!(df,n)
    nrows, ncols = size(df)

    for i in 1:nrows
        for j in 1:ncols
            if typeof(df[i,j]) <: AbstractFloat
                s = split("$(df[i,j])", ".")
                df[i,j] = "$(s[1]).$(rpad(s[2],n,"0"))"
            end
        end
    end

    return df
end

"""
    rpaddf(df,n)

Rightpad all numerical values with zeros to have n decimal digits.
"""
function rpaddf(df,n)
    _df = deepcopy(df)
    return rpaddf!(_df,n)
end

"""
    mergedfs(ldf, rdf)

Merges DataFrames for the article purpose.
"""
function mergedfs(ldf, rdf)
    nrows, ncols = size(ldf)
    @assert (nrows, ncols) == size(rdf)

    df = deepcopy(ldf)

    # first merge all cells
    for i in 1:nrows
        for j in 2:ncols
            df[i,j] = "$(df[i,j])($(rdf[i,j]))"
        end
    end

    return df
end
