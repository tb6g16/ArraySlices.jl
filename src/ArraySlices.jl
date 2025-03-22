# __precompile__()
module ArraySlices

import Base: length, size, eltype, getindex, Slice, OneTo

export slices, columns, rows

# TODO: overload printing methods
# Type parameters
# 
# F : type of SubArray
# D : tuple of indexed dimensions of the array
# N : number of indexed dimensions
# A : array type
struct SliceIterator{F, D, N, A<:AbstractArray} <: AbstractArray{F, N}
    array::A
end

"""
    slices(array, dims)

Return a `SliceIterator` object to loop over the slices of `array` along the
dimensions `dims`. 

"""
function slices(array::AbstractArray{T, M}, ::Val{D}) where {T, M, D}
    # checks
    prod(1 .<= D .<= M) || throw(ArgumentError("invalid slice dimension"))

    # construct type of slice
    # example: SubArray{Float64, 1, Array{Float64,2}, Tuple{Int64, Colon}, true}
    N = length(D)
    # TODO: do I even need to this type parameter, since it doesn't provide any new information and isn't used in the interface
    F = SubArray{T, M - N, typeof(array), Tuple{[j ∈ D ? Int : Slice{OneTo{Int64}} for j = 1:M]...}, _get_L(D, M)}

    # build and return iterator
    SliceIterator{F, D, length(D), typeof(array)}(array)
end

_get_L(D::Int, M) = D == 1 || D == M ? true : false
function _get_L(D::Tuple, M)
    slice_inds = filter(x -> !(x ∈ D), 1:M)
    for i in 1:(length(slice_inds) - 1)
        if slice_inds[i] != slice_inds[i + 1] - 1
            return false
        end
    end
    return true
end

# ~~~ Array interface ~~~
eltype(s::SliceIterator{F}) where {F} = F
size(s::SliceIterator{F, D, 1}) where {F, D} = (size(s.array, D),)
size(s::SliceIterator{F, D}) where {F, D} = map(dim -> size(s.array, dim), D)
length(s::SliceIterator) = prod(size(s))

# build code that produces slices with the correct indexing
@generated function getindex(s::SliceIterator{F, D, N, A}, i::Integer) where {F, D, N, A}
    args = [j ∈ D ? :(i) : :(Colon()) for j = 1:ndims(A)]
    return :(view(s.array, $(args...)))
end


# ~~~ Convenience functions for 2D arrays ~~~

"""
    columns(array)

Return a `SliceIterator` object to loop over the columns of `array`.

"""
columns(array::AbstractMatrix) = slices(array, Val(2))

"""
    rows(array)

Return a `SliceIterator` object to loop over the rows of `array`.

"""
rows(array::AbstractMatrix) = slices(array, Val(1))

end