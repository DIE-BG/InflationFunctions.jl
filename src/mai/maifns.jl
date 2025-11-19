# Construct vlp and wlp from CountryStructure
function historical_distr(cst::CountryStructure)

    vlp = mapreduce(base -> vec(base.v), vcat, cst.base)
    o = sortperm(vlp)
    sort!(vlp)

    w = mapreduce(vcat, cst.base) do base
        T = periods(base)
        wb = repeat(base.w', T)
        vec(wb)
    end
    wlp = w[o]

    # Return historical distribution with associated weights
    return vlp, wlp
end


# Computes the numbers of the special segment
function get_segments(q_cp, q_lp)
    K = length(q_lp) 
    # Obtener número de percentiles que conforman segmento especial en la
    # disribución de largo plazo
    k̄ = something(findfirst(>(0), q_lp), K)
    k̲ = something(findlast(<(0), q_lp), 0)
    # Obtener número de percentiles que conforman segmento especial en la
    # disribución del mes o ventana
    s̄ = something(findfirst(>(0), q_cp), K)
    s̲ = something(findlast(<(0), q_cp), 0)
    # Obtener los números comunes
    r̲ = min(k̲, s̲)
    r̄ = max(k̄, s̄)
    return r̲, r̄
end

# Computes the indexes corresponding to quantiles vq in the distribution vdistr
function qindexes(vq, vdistr)
    indexvec = [findlast(<=(vq[i]), vdistr) for i in eachindex(vq)]
    return indexvec
end

# Returns a list of ranges in vdistr that divide the segments using indexes indexvec.
# Takes into account the special segment, indicated by rl and ru
function segmentranges(indexvec, rl, ru, vdistrlen)
    # number of segments
    K = length(indexvec) + 1
    ranges = map(1:K) do k
        # start index
        start = rl == 0 ? 1 : indexvec[rl] + 1
        # within special segment, empty range
        rl < k < ru && (return (start + 1):start)
        # first segment
        k == 1 && (return 1:indexvec[k])
        # special segment
        k == ru && (return start:indexvec[ru])
        # last segment
        k == K && (return (indexvec[end] + 1):vdistrlen)

        # any other segment
        ((indexvec[k - 1] + 1):indexvec[k])
    end
    return ranges
end

# MAI-G variant
function _mai_g_mm(base, q, vlp, wlp)
    vqlp = quantile(vlp, aweights(wlp), q)
    N = length(vlp)
    aw = aweights(base.w)
    T = periods(base)
    vmbase = similar(vlp, T)

    Threads.@threads for t in 1:T
        v = @view base.v[t, :]
        # Find quantiles
        vq = quantile(v, aw, q) # weighted quantiles
        # Get segments
        rl, ru = get_segments(vq, vqlp)
        # Find quantile indexes in vlp
        Ng = qindexes(vq, vlp)
        # Get a vector of ranges for the segments
        r = segmentranges(Ng, rl, ru, N)

        # Get the summary monthly price change
        vmperiod = mapreduce(+, enumerate(r)) do (i, r_)
            isempty(r_) && return 0

            if i == ru
                # if in special segment
                q0 = rl == 0 ? zero(eltype(q)) : q[rl]
                p = q[ru] - q0
            elseif i == 1
                # first segment (when it's not the special)
                p = q[1]
            elseif i == length(r)
                # last segment
                p = one(eltype(q)) - q[i - 1]
            else
                # any other intermediate segment
                p = q[i] - q[i - 1]
            end

            # weighted
            vwlp = @view wlp[r_]
            p * sum(vlp[i] * wlp[i] for i in r_) / sum(vwlp)
        end
        vmbase[t] = vmperiod
    end
    # Return the monthly price changes
    return vmbase
end

# MAI-F
function _mai_f_mm(base, q, vlp)
    vqlp = quantile(vlp, q)
    N = length(vlp)
    T = periods(base)
    vmbase = similar(vlp, T)

    Threads.@threads for t in 1:T
        v = @view base.v[t, :]
        # Find quantiles
        vq = quantile(v, q)
        # Get segments
        rl, ru = get_segments(vq, vqlp)
        # Find quantile indexes in vlp
        Nf = qindexes(vq, vlp)
        # Get a vector of ranges for the segments
        r = segmentranges(Nf, rl, ru, N)

        # Get the summary monthly price change
        vmperiod = mapreduce(+, enumerate(r)) do (i, r_)
            isempty(r_) && return 0

            if i == ru
                # if in special segment
                q0 = rl == 0 ? zero(eltype(q)) : q[rl]
                p = q[ru] - q0
            elseif i == 1
                # first segment (when it's not the special)
                p = q[1]
            elseif i == length(r)
                # last segment
                p = one(eltype(q)) - q[i - 1]
            else
                # any other intermediate segment
                p = q[i] - q[i - 1]
            end

            # unweighted
            vvlp = @view vlp[r_]
            p * mean(vvlp)
        end
        vmbase[t] = vmperiod
    end
    # Return the monthly price changes
    return vmbase
end


# MAI-FG variant
function _mai_fg_mm(base, q, vlp, wlp)
    vflp = quantile(vlp, q)
    sumwlp = sum(wlp)
    N = length(vlp)
    T = periods(base)
    vmbase = similar(vlp, T)

    Threads.@threads for t in 1:T

        v = @view base.v[t, :]
        # Find quantiles
        vq = quantile(v, q)
        # Get segments
        rl, ru = get_segments(vq, vflp)
        # Find N values in flp and glp
        Ng = qindexes(vq, vlp)
        Nf = qindexes(vflp, vlp)

        # Get a vector of ranges for the long-term weighted distribution
        rg = segmentranges(Ng, rl, ru, N)
        # Get a vector of ranges for the long-term weighted distribution evaluated at the
        # long-term unweighted quantiles. This is to compute the normalization constant
        rf = segmentranges(Nf, rl, ru, N)

        # Get the summary monthly price change
        vmperiod = mapreduce(+, 1:length(rg)) do i
            # Get index ranges for the segments
            rg_ = rg[i]
            rf_ = rf[i]
            # If a segment is empty, no need to normalize
            isempty(rg_) && return 0

            # Compute new weight for segment
            vwlp = @view wlp[rf_]
            p = sum(vwlp) / sumwlp

            # Compute weighted average
            vwlp = @view wlp[rg_]
            p * sum(vlp[i] * wlp[i] for i in rg_) / sum(vwlp)
        end
        vmbase[t] = vmperiod
    end
    # Return the monthly price changes
    return vmbase
end
