//
//  AvatarBackgroundRenderer.swift
//  HeavyMetal
//
//  Created by Lorenzo Tognalini on 25.02.25.
//

import Metal

class AvatarBackgroundRender: AvatarRenderer {
    
    let renderPipelineState: MTLRenderPipelineState
    
    init(metalDevice: MTLDevice, pixelFormat: MTLPixelFormat) {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        let library = metalDevice.makeDefaultLibrary()!
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "backgroundVertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "backgroundFragmentShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        pipelineDescriptor.maxVertexAmplificationCount = 1
        
        renderPipelineState = try! metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        // we want to apply twice, once er eye. must be < maxVertexAmplificationCount
        renderEncoder.setVertexAmplificationCount(1, viewMappings: nil)
        
        // We tell it what render pipeline to use
        renderEncoder.setRenderPipelineState(renderPipelineState)
        
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//        renderEncoder.setVertexBuffer(loudnessUniformBuffer, offset: 0, index: 1)
//        renderEncoder.setVertexBuffer(freqeuencyBuffer, offset: 0, index: 2)
//        // triangleStrip makes sure the triangles overlap properly and no artifacts are shown
//        renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: 1081, vertexCount: 1081)
//        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 1081)
    }
    
}
