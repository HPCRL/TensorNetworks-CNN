# GPU Implementation of the Decomposed CNN with Tensor Networks 
This work is the extention of the paper title "Fast GPU Convolution for CP-decomposed Tensorial Neural Networks"

# ParallelTNNLayers
Parallel implementations of decomposed tensorial neural network layers

## Instructions to reproduce results

#### Requirements
Tests and Benchmarks require Tensorflow, Python 3.x and a GPU capable of running Tensorflow along with CUDA and CUDNN libraries installed.

#### Instructions

To build Custom Fused operations:

1. `cd Kernels`
1. Modify the Makefile 'Vars specific to local development machine' section for your personal machine. This requires setting your CUDA architecture string along with locations of CUDA headers and libraries. 
1. `make `
1. `cd ..`

To run tests and benchmarks enter the `test` directory and execute the individual python scripts. We've also written a simple script `run_all.sh` to execute all tests and benchmarks directly.

`cd test && ./run_all.sh && cd ..`

To generate plots on past data:

`cd results && python generate_plots.py`

## Custom Fused Kernels

Cuda kernels and tensorflow C++ wrappers needed to register custom operations
can be found in the `Kernels` directory. `*.cu` files are auto-tuned CUDA kernels, while
the associated `*.cc` files are C++ wrapper codes that expose the custom fused kernels to
tensorflow.

## Sequencer

In the \sequences, you will find an updated version of netcon which can handle generalized tensor operations.
The formatting for bond names is very sensitive, please read below:

        **FORMATTING**
        The bond/leg lists require sensitive formatting. Please read below.

        -Leg names must be of type string. Use *lower-case* letter-number combinations,
        EXCEPT in the case of convolution and partial outer product (see below):

        -Bond legs should be in the same order as the dimensions listed by tf.get_shape()

        -For outer product, just use different leg names.
        Example: [i0,j,k] & [k,l,m1] have no common indices, so an outer product is performed.

        -For convolution, append * to the end of leg name, use same leg name, but with different casing.
        We assume here that convolution between i & j pads the new leg to dimension length of max(i,j).
        USE LOWER CASE FOR THE LEG WITH HIGHER DIMENSION.

        Example: [a,b*,c] & [d,B*,e] will convolve between the b*/B* indices.
        Please note that this assumes the convolution for a particular leg is only between two tensors.
        I.e., [a,b*,c] & [d,B*,e] & [f, b*, h] is NOT valid.

       -For partial outer product, append + to end of leg names, with upper and lower casing.
        Example: [n,p+,q] & [r,P+,s] will perform a partial outer product between p+/P+ indices.

       -For contraction, just leave the leg names the same.
        Example" [i0,j3,k] & [i0,l2,m] will contract between the i indices.

        Example of a tensor network with multiple tensor operations.

        Here, we are contracting on bonds j between A & B, convolving on bonds j&J between A & C
        and taking a partial outer product on bond k between C & D.
        We would express the bonds as follows:
        A_bonds = [j,q*]
        B_bonds = [j,l,m]
        C_bonds = [Q*, k+]
        D_bonds = [n, K+, p]

            q   Q
          A---^---C
          |       |
        j |       = k
          |       |
          B       D
         / \     / \
        l   m   n   p


