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
//vector_float2 varName;


/// If you don’t include the`[[position]]` attribute in the struct, then you’ll get a compile error telling you that `VertexOut`     is an invalid return type.
/// If you’re only passing out a `vector_float4` with no struct, metal will automatically inference it to being the coordinates.
struct VertexOut {
    vector_float4 position [[position]];
    vector_float4 color;
};


/// - Parameters:
///     - vertexArray: array of vertex points that we’ll be passing in
///     - loudnessUniform: single scalar for the magnitude of the laudness
///     - vid: “vector id”. This uniquely identifies which vertex we’re currently on; it will be used as the index for our vertexArray
/// - Returns:
///     The output is of type VertexOut, which holds a position vector and a color vector.
vertex VertexOut vertexShader(const constant vector_float2 *vertexArray [[buffer(0)]],
                              const constant float *loudnessUniform [[buffer(1)]],
                              const constant float *lineArray[[buffer(2)]],
                              unsigned int vid [[vertex_id]])
{
    
    VertexOut output;
    
    if (vid < 1081) {
        float circleScaler = loudnessUniform[0];
        //fetch the current vertex we're on using the vid to index into our buffer data which holds all of our vertex points that we passed in
        vector_float2 currentVertex = vertexArray[vid];
        
        //populate the output position with the x and y values of our input vertex data
        output.position = vector_float4(currentVertex.x * circleScaler * 0.2 - 0.5,
                                        currentVertex.y * circleScaler * 0.2 + 0.5, 0, 1);
//        output.color = vector_float4(0,0,0,1); //black
        output.color = vector_float4(0.04, 0.74, 0.78, 1); // cyan
//        output.color = vector_float4(0.04, 0.09, 0.2, 1); // blue
        
    } else {
        int circleId = vid-1081;
        vector_float2 circleVertex;
        float circleScaler = 0.6 - (loudnessUniform[0]*0.1);

        if (circleId%3 == 0) {
            //place line vertex off circle
            circleVertex = vertexArray[circleId];
            float lineScale = 1 + lineArray[(vid-1081)/3];
            output.position = vector_float4(circleVertex.x * circleScaler * lineScale * 0.5 - 0.5,
                                            circleVertex.y * circleScaler * lineScale * 0.4 + 0.5, 0, 1);
            output.color = vector_float4(0.92, 0, 0.85, 1); // fucsia
        } else {
            //place line vertex on circle
            circleVertex = vertexArray[circleId-1];
            output.position = vector_float4(circleVertex.x * circleScaler * 0.5 - 0.5,
                                            circleVertex.y * circleScaler * 0.4 + 0.5, 0, 1);
            // output.color = vector_float4(0.04, 0.09, 0.2, 1); // blue
            output.color = vector_float4(0.04, 0.74, 0.78, 1); // cyan
        }
    }
    
    return output;
};

/// - Parameters:
///     - interpolated: The [[stage_in]] attribute tells the metal that the variable should be fed in the interpolated result of the rasterizer.
/// - Returns:
///     The output is just an <R, G, B, A> color that we fetch from the VertexOut struct that was passed through from the vertexShader function.
fragment vector_float4 fragmentShader(VertexOut interpolated [[stage_in]]){
    return interpolated.color;
};
