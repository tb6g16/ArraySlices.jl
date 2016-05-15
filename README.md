# ArraySlices.jl

This is a very simple Julia package that enables looping over slices of an array in a natural way. Here is a demo:

````julia
# have some array
x = randn(10, 50)

# loop over the columns
for col in columns(x)
  # do some work 
  do_some_work_on_col(col)
end
```

## Installation

This package is not registered, hence installation follows the general procedure for Julia code on a Github repository:
```julia
Pkg.clone("https://github.com/gasagna/ArraySlices.jl.git")
```

## Api description
There is no documentation yet, and probably never will be, as the api is very simple. This main function exported by this module is `slices`. For a given array `x`, `slices(x, i)` returns a `SlicesIterator` object, to loop over the slices of `x` along dimension `i`. For instance:

````julia
x = randn(2, 3, 4)
for sl in slices(x, 1)
  # the sl are 3x4 SubArrays
end
```

or 

````julia
x = randn(2, 3, 4)
for sl in slices(x, 2)
  # the sl are 2x4 SubArrays
end
```
and so on. 

Two convenience functions, `columns` and `rows`, are also provided to loop over the columns and rows of two dimensional arrays. 

````julia
# some data
X = [1 1;
     2 2]

for col in columns(X)
  # col is equal to a [1, 2] array
end

for (i, row) in enumerate(rows(X))
  # row is equal to a i*[1, 1] array
end
````


## Why did you do this?
I created this package because I frequently have to map functions working 
in-place over some input and output data organised into arrays. For instance, 
in the example below, the function `J!` maps vectors to matrices, 
(e.g. the jacobian of a vector function). This package can be used to apply `J!`
to each column of `X`, storing the output in the corresponding slices of 
the preallocated `Y` array. 

````julia
# map a 1-dimension array to a 2-dimension array
J!{T}(y::AbstractArray{T, 2}, x::AbstractArray{T, 1}) = # blah blah

# input data, i.e. fifty vectors of length 10
X = randn(10, 50)

# output is preallocated, fifty 10x10 matrices
Y = Array{Float64}(10, 10, 50) 

# apply f! to each slice - (uses foreach!, available in v0.5 only)
foreach(J!, slices(Y, 3), slices(X, 2))
````





