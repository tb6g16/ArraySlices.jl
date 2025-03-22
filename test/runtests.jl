using Test

using ArraySlices

# TODO: add tests for more varied slice dimension options
@testset "Slices                " begin
    # check constructor
    for nd = 2:5
        X = randn(rand(1:10, nd)...)
        @test_throws ArgumentError slices(X, Val(0))
        @test_throws ArgumentError slices(X, Val(nd+1))
    end
    # X = randn(rand(1:10, 5)...)
    # @show typeof(slices(X, Val(2)))
    # @show typeof(slices(X, Val((1, 3))))

    # check length and size of slices
    X = randn(1, 2, 3, 4, 5, 6)
    for i = 1:ndims(X)
        @test length(slices(X, Val(i))) == i
        @test size(slices(X, Val(i))) == (i, )
    end

    # check compatibility with views
    X = randn(5, 5, 5, 5, 5)
    @test typeof(view(X, 1, :, :, :, :)) == eltype(slices(X, Val(1)))
    @test typeof(view(X, :, 1, :, :, :)) == eltype(slices(X, Val(2)))
    @test typeof(view(X, :, :, 1, :, :)) == eltype(slices(X, Val(3)))
    @test typeof(view(X, :, :, :, 1, :)) == eltype(slices(X, Val(4)))
    @test typeof(view(X, :, :, :, :, 1)) == eltype(slices(X, Val(5)))
end

@testset "Row and column methods" begin
    # check columns method
    X = [1  2  3; 
        4  8 12; 
        9 18 27]
    cols = columns(X)
    @test cols[1] == [1, 4, 9]

    # check iteration over rows and columns
    X = [1  2  3; 
        4  8 12; 
        9 18 27]
    for (i, col) in enumerate(columns(X))
        @test col == [i, 4i, 9i]
    end 
    for (i, row) in enumerate(rows(X))
        @test row == i^2*[1, 2, 3]
    end 

    for (c1, c2) in zip(columns(X), rows(X'))
        @test c1 == c2
    end
end
