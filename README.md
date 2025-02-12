# swift-metal-resources

Studying Metal and Accelerate API for Audio Processing and Visualization

### Resources used:

##### Metal Shaders 
- https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf
- https://developer.apple.com/documentation/metal/using-a-render-pipeline-to-render-primitives
- https://medium.com/better-programming/making-your-first-circle-using-metal-shaders-1e5049ec8505

##### Accelerate
- https://medium.com/better-programming/audio-visualization-in-swift-using-metal-accelerate-part-1-390965c095d7
- https://medium.com/better-programming/audio-visualization-in-swift-using-metal-accelerate-part-2-7ec8df4def91
- https://github.com/barbulescualex/MetalAudioVisualizer/tree/master/starter/AudioVisualizer
- https://developer.apple.com/documentation/accelerate check `vdsp`

##### SIMD 
Image processing and CPU computing algorithms and data structures

- https://github.com/ermig1979/Simd


## DSP Analsys

### Loudness

The best option we have in the vDSP framework is the root **means squared calculation**. 
This makes sense since the RMS is used to calculate the average of a function that goes above and below the x-axis. 
It also turns out that in practice, this is a very good and well-used measurement technique for loudness.

More accurately: look into **A-Weighting** which will put a heavier emphasis on the frequencies our ears can hear better.

