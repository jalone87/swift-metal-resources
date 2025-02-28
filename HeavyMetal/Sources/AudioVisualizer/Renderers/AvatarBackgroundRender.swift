//
//  AvatarBackgroundRenderer.swift
//  HeavyMetal
//
//  Created by Lorenzo Tognalini on 25.02.25.
//

import Metal
import simd

class AvatarBackgroundRender: AvatarRenderer {
    
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
    
    private var initialMagnitude: Float = 0
    private var initialFrequencies = [Float](repeating: 0, count: 361)
    
    init(metalDevice: MTLDevice,
         pixelFormat: MTLPixelFormat,
         vertexBuffer: MTLBuffer)
    {
        self.metalDevice = metalDevice
        
        self.vertexBuffer = vertexBuffer
        self.loudnessUniformBuffer = Self.createLodnessBuffer(&initialMagnitude, metalDevice: metalDevice)
        self.freqeuencyBuffer = Self.createFrequenciesBuffer(&initialFrequencies, metalDevice: metalDevice)
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        let library = metalDevice.makeDefaultLibrary()!
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "backgroundVertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "backgroundFragmentShader")
        pipelineDescriptor.maxVertexAmplificationCount = 1
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        // the followings allow translucent colors
//        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
//        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
//        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
//        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
//        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
//        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
//        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        
        renderPipelineState = try! metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        
        renderEncoder.setVertexAmplificationCount(1, viewMappings: nil)
        
        renderEncoder.setRenderPipelineState(renderPipelineState)
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(loudnessUniformBuffer, offset: 0, index: 1)
        renderEncoder.setVertexBuffer(freqeuencyBuffer, offset: 0, index: 2)

        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 1081, vertexCount: 1081)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 1081)
    }
    
}
