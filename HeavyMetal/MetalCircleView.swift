//
//  MetalCircleView.swift
//  HeavyMetal
//
//  Created by Lorenzo Tognalini on 06.02.25.
//

import Cocoa
import MetalKit
import simd

let varName: simd_float2

/// from https://medium.com/better-programming/making-your-first-circle-using-metal-shaders-1e5049ec8505
class MetalCircleView: NSView, MTKViewDelegate {
    
    // MARK: - View Propperties
    
    /// Responsible to draw the clipped metal output
    private var metalView = MTKView()
    
    /// represents the GPU
    private var metalDevice: MTLDevice!
    
    private var metalCommandQueue: MTLCommandQueue!
    
    // MARK: - Data Propperties
    
    
    
    // MARK: - Init
    
    public required init() {
        super.init(frame: .zero)
        setupView()
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
        
        //updates
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = true
        
        //connect to the gpu
        metalDevice = MTLCreateSystemDefaultDevice()
        metalView.device = metalDevice
        
        //creating the command queue
        metalCommandQueue = metalDevice.makeCommandQueue()!
        
        metalView.needsDisplay = true

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
        
        /*********** We'll be encoding commands here **************/
        
        // end the encoding and fire off the commandBuffer to be executed on the GPU
        renderEncoder.endEncoding()
        
        // display  in the view. currentDrawable is a drawable representing the current frame
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
        
    }
}
