//
//  shaders.metal
//  HeavyMetal
//
//  Created by Lorenzo Tognalini on 08.02.25.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;


// source: https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf

// using SIMD https://ermig1979.github.io/Simd/ for vectors
vector_float2 varName;
