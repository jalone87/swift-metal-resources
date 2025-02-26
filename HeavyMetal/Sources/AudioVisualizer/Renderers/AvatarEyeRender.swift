//
//  AvatarEyeRender.swift
//  HeavyMetal
//
//  Created by Lorenzo Tognalini on 25.02.25.
//

import MetalKit
import simd

protocol AvatarRenderer {
    
    // To use MTLRenderCommandEncoder to encode commands for a rendering pass,
    // specify a MTLRenderPipelineState object that defines the graphics state,
    // including vertex and fragment shader functions, before issuing any draw calls.
    // To create a pipeline state, we need a MTLRenderPipelineDescriptor
    //var renderPipelineState: MTLRenderPipelineState { get }
    
}

class AvatarEyeRender: AvatarRenderer {
    
    private let metalDevice: MTLDevice
    private let renderPipelineState: MTLRenderPipelineState
    
    private let vertexBuffer: MTLBuffer
    private var loudnessUniformBuffer: MTLBuffer
    private var freqeuencyBuffer: MTLBuffer
    
    func updateLoudness(_ magnitude: inout Float) {
        loudnessUniformBuffer = Self.createLodnessBuffer(&magnitude, metalDevice: metalDevice)
    }
    
    static private func createLodnessBuffer(_ magnitude: inout Float, metalDevice: MTLDevice) -> MTLBuffer {
        return metalDevice.makeBuffer(
            bytes: &magnitude,
            length: MemoryLayout<Float>.stride,
            options: []
        )!
    }
    
    func updateFrequencies(_ frequencies: inout [Float]) {
        var sliced = Array(frequencies[76..<438])
        freqeuencyBuffer = Self.createFrequenciesBuffer(&sliced, metalDevice: metalDevice)
    }
    
    static func createFrequenciesBuffer(_ frequencies: inout [Float], metalDevice: MTLDevice) -> MTLBuffer {
        return metalDevice.makeBuffer(
            bytes: frequencies,
            length: frequencies.count * MemoryLayout<simd_float2>.stride,
            options: []
        )!
    }
    
    init(metalDevice: MTLDevice,
         pixelFormat: MTLPixelFormat,
         vertexBuffer: MTLBuffer)
    {
        self.metalDevice = metalDevice
        
        self.vertexBuffer = vertexBuffer
        
        var initialMagnitude: Float = 0
        self.loudnessUniformBuffer = Self.createLodnessBuffer(&initialMagnitude, metalDevice: metalDevice)
        var initialFrequencies = [Float](repeating: 0, count: 361)
        self.freqeuencyBuffer = Self.createFrequenciesBuffer(&initialFrequencies, metalDevice: metalDevice)
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        // maximum number of times the shader can be called with the same id
        // (to avoid recalculating or duplicating  the input)
        pipelineDescriptor.maxVertexAmplificationCount = 2
        
        //finds the metal file from the main bundle
        let library = metalDevice.makeDefaultLibrary()!
        
        //give the names of the function to the pipelineDescriptor
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "eyeVertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "eyeFragmentShader")
        
        //set the pixel format to match the MetalView's pixel format
        pipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        
        //make the pipelinestate using the gpu interface and the pipelineDescriptor
        renderPipelineState = try! metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func render(_ renderEncoder: MTLRenderCommandEncoder)
    {
        // we want to apply twice, once er eye. must be < maxVertexAmplificationCount
        renderEncoder.setVertexAmplificationCount(2, viewMappings: nil)
        
        // We tell it what render pipeline to use
        renderEncoder.setRenderPipelineState(renderPipelineState)
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(loudnessUniformBuffer, offset: 0, index: 1)
        renderEncoder.setVertexBuffer(freqeuencyBuffer, offset: 0, index: 2)
        // triangleStrip makes sure the triangles overlap properly and no artifacts are shown
        renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: 1081, vertexCount: 1081)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 1081)
    }
    
}
