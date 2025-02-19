//
//  AudioVisualizerView.swift
//  HeavyMetal
//
//  Created by Lorenzo Tognalini on 09.02.25.
//

import Cocoa
import MetalKit
import simd

/// from https://medium.com/better-programming/making-your-first-circle-using-metal-shaders-1e5049ec8505
class AudioVisualizerView: NSView, MTKViewDelegate {
    
    // MARK: - View Propperties
    
    /// Responsible to draw the clipped metal output
    private var metalView = MTKView()
    
    /// represents the GPU
    private var metalDevice: MTLDevice!
    
    /// the flow of commands to a gpu buffer
    private var metalCommandQueue: MTLCommandQueue!
    
    private var metalRenderPipelineState : MTLRenderPipelineState!
    
    // MARK: - Data Properties
    
    /// Array of vectors (SIMD library vectors) that hold x and y coordinates for consecutive triangles
    var circleVertices = [simd_float2]()
    
    private var vertexBuffer: MTLBuffer!
    
    private var loudnessUniformBuffer : MTLBuffer! // TODO: this is not initialized first time
    public var loudnessMagnitude: Float = 0.3 {
        didSet{
            loudnessUniformBuffer = metalDevice.makeBuffer(bytes: &loudnessMagnitude,
                                                           length: MemoryLayout<Float>.stride,
                                                           options: [])!
        }
    }
    
    // MARK: - Init
    
    public required init() {
        super.init(frame: .zero)
        setupView()
        createVertexPoints()
        setupMetal()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    fileprivate func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
 
    }
    
    fileprivate func setupMetal(){
        //view
        addSubview(metalView)
        
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        metalView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        metalView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        metalView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        metalView.delegate = self
        
        //updates are automatic. these shall be enabled only if we want to disable automatic metal updates
        // metalView.isPaused = true
        // metalView.enableSetNeedsDisplay = true
        
        //connect to the gpu
        metalDevice = MTLCreateSystemDefaultDevice()
        metalView.device = metalDevice
        
        //creating the command queue
        metalCommandQueue = metalDevice.makeCommandQueue()!
        
        //creating the render pipeline state
        createPipelineState()
        
        //creates a MTLBuffer object by copying data from an existing storage allocation into a new allocation.
        //turn the vertex points into buffer data
        vertexBuffer = metalDevice.makeBuffer(bytes: circleVertices,
                                              length: circleVertices.count * MemoryLayout<simd_float2>.stride,
                                              options: [])!
        
        //initialize the freqeuencyBuffer data
        loudnessUniformBuffer = metalDevice.makeBuffer(bytes: &loudnessMagnitude,
                                                       length: MemoryLayout<Float>.stride,
                                                       options: [])!

        //draw
        metalView.needsDisplay = true

    }
    
    // To use MTLRenderCommandEncoder to encode commands for a rendering pass,
    // specify a MTLRenderPipelineState object that defines the graphics state,
    // including vertex and fragment shader functions, before issuing any draw calls.
    // To create a pipeline state, we need a MTLRenderPipelineDescriptor
    fileprivate func createPipelineState(){
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        //finds the metal file from the main bundle
        let library = metalDevice.makeDefaultLibrary()!
        
        //give the names of the function to the pipelineDescriptor
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        
        //set the pixel format to match the MetalView's pixel format
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        //make the pipelinestate using the gpu interface and the pipelineDescriptor
        metalRenderPipelineState = try! metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
    }
    
    // MARK: - MTKViewDelegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        //not worried about this
    }
    
    func draw(in view: MTKView) {
        //Creating the commandBuffer for the queue
        //This will contain the instructions we need to execute our commands
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer() else {return}
        
        //Creating the interface for the pipeline, MTLRenderPassDescriptor. Use defaut one from `currentRenderPassDescriptor`.
        guard let renderDescriptor = view.currentRenderPassDescriptor else {return}
        //Setting a "background color"
        renderDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 1, 1)
        
        //Creating the command encoder, MTLRenderCommandEncoder, or the "inside" of the pipeline
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor) else {return}
        
        // We tell it what render pipeline to use
        renderEncoder.setRenderPipelineState(metalRenderPipelineState)
        
        // --- We'll be encoding commands here --- //
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(loudnessUniformBuffer, offset: 0, index: 1)
        // triangleStrip makes sure the triangles overlap properly and no artifacts are shown
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 1081)
        
        // --- end --- //
        
        // end the encoding and fire off the commandBuffer to be executed on the GPU
        renderEncoder.endEncoding()
        
        // display  in the view. currentDrawable is a drawable representing the current frame
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
        
    }
    
    private func createVertexPoints(){
        
        // we want to create a disc, made of triangles in a circle
        func rads(forDegree d: Float)->Float32{
            return (Float.pi*d)/180
        }
        
        let origin = simd_float2(0, 0)

        for i in 0...720 {
            let degree = Float(Float(i)/2.0)
            let position: simd_float2 = [cos(rads(forDegree: degree)),
                                         sin(rads(forDegree: degree))]
            circleVertices.append(position)
            
            if (i+1)%2 == 0 {
                circleVertices.append(origin)
            }
        }
        
        // Clip space is a 2D coordinate system that maps the viewport area to a [-1.0, 1.0]
        // this will match the MTKView viewport area (unless we override/redefine it)
        
    }
}
