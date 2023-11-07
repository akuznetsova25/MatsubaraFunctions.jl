# unsafe method for to grid index
function grid_index(
    w    :: MatsubaraFrequency{PT},
    grid :: MatsubaraGrid{PT}
    )    :: Int64 where {PT <: AbstractParticle}

    @DEBUG temperature(w) ≈ temperature(grid) "Temperature must be equal between frequency and grid"
    return index(w) - first_index(grid) + 1
end

function grid_index(
    w    :: MatsubaraIndex{PT},
    grid :: MatsubaraGrid{PT}
    )    :: Int64 where {PT <: AbstractParticle}

    return index(w) - first_index(grid) + 1
end

# safer method for converting to grid index
function grid_index_extrp(
    w    :: AbstractMatsubaraFrequency,
    grid :: AbstractMatsubaraGrid
    )    :: Int64 

    return max(1, min(grid_index(w, grid), length(grid)))
end

function Base.:eachindex(
    grid :: AbstractMatsubaraGrid
    )    :: Base.OneTo{Int64}

    return eachindex(grid.data)
end

function Base.:firstindex(
    grid :: AbstractMatsubaraGrid
    )    :: Int64

    return firstindex(grid.data)
end

function Base.:lastindex(
    grid :: AbstractMatsubaraGrid
    )    :: Int64

    return lastindex(grid.data)
end

function Base.:getindex(
    grid :: AbstractMatsubaraGrid,
    idx  :: Int64 
    )    :: MatsubaraFrequency

    return grid.data[idx]
end

function Base.:getindex(
    grid :: AbstractMatsubaraGrid,
    x    :: AbstractMatsubaraFrequency
    )    :: MatsubaraFrequency

    return grid[grid_index(x, grid)]
end

function Base.:getindex(
    grid :: AbstractMatsubaraGrid,
    idxs :: UnitRange{Int64}
    )    :: SubArray{MatsubaraFrequency, 1, Vector{MatsubaraFrequency}, Tuple{UnitRange{Int64}}, true}

    return @view grid.data[idxs]
end  

#----------------------------------------------------------------------------------------------#

# returns index to data array corresponding to this frequency if in grid
function (f :: AbstractMatsubaraGrid)(
    w :: AbstractMatsubaraFrequency
    ) :: Int64

    if is_inbounds(w, f)
        return grid_index(w, f)
    else 
        error("Frequency index not in grid")
    end 
end

# returns index to data array corresponding to closest frequency if in grid
function (f :: AbstractMatsubaraGrid)(
    w :: Float64
    ) :: Int64

    if is_inbounds(w, f)
        delta    = value(f[2]) - value(f[1])
        position = (w - value(f[1])) / delta
        return round(Int64, position) + 1
    else 
        error("Frequency not in grid")
    end 
end

#----------------------------------------------------------------------------------------------#

function Base.:iterate(
    grid :: AbstractMatsubaraGrid
    )    :: Tuple{MatsubaraFrequency, Int64}

    return grid[1], 1 
end

function Base.:iterate(
    grid  :: AbstractMatsubaraGrid,
    state :: Int64
    )     :: Union{Nothing, Tuple{MatsubaraFrequency, Int64}}

    if state < length(grid)
        return grid[state + 1], state + 1 
    else 
        return nothing 
    end
end