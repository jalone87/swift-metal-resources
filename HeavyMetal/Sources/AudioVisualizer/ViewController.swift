//
//  ViewController.swift
//  HeavyMetal
//
//  Created by Lorenzo Tognalini on 06.02.25.
//

import Cocoa
import AVFoundation
import Accelerate

class ViewController: NSViewController {
    
    var engine = AVAudioEngine()
    var audioVisualizerView: AudioVisualizerView = AudioVisualizerView()
    
    /// allows interpolating values in the UI, since the data tap is only every 0.1s
    var prevRMSValue: Float = SignalProcessing.minMagnitudeLevel
    
    /// fft setup object for 1024 values going forward (time-> frequency)
    /// https://developer.apple.com/documentation/accelerate/1450061-vdsp_dft_zop_createsetup
    /// to be fed to https://developer.apple.com/documentation/accelerate/1450538-vdsp_dft_execute
    let fftSetup = vDSP_DFT_zop_CreateSetup(nil, 1024, vDSP_DFT_Direction.FORWARD)
    
    // TODO: destroy the setup object after it's not eneded anymore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(audioVisualizerView)
        
        self.view.wantsLayer = true
        self.view.layer?.isOpaque = false
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
        
        //constraining to window
        audioVisualizerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        audioVisualizerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        audioVisualizerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        audioVisualizerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        setupAudio()
    }
    
    func setupAudio() {
        
        /* Setup & Start Engine */
        
        //initializing the mainMixerNode singleton which will connect to the default output node
        _ = engine.mainMixerNode
        
        //prepare and start
        engine.prepare()
        do {
            try engine.start()
        } catch {
            print(error)
        }
        
        /* Setup Player Node */

        //first we need the resource url for our file
        guard let url = Bundle.main.url(forResource: "music", withExtension: "mp3") else {
            print("mp3 not found")
            return
        }
        
        //now we need to create our player node
        let player = AVAudioPlayerNode()

        do {
            //player nodes have a few ways to play-back music, the easiest way is from an AVAudioFile
            let audioFile = try AVAudioFile(forReading: url)

            //audio always has a format, lets keep track of what the format is as an AVAudioFormat
            let format = audioFile.processingFormat

            //we now need to connect add the node to our engine. This part is a little weird but we first need
            //to attach it to the engine itself before connecting it to the mainMixerNode. Recall that the
            //mainMixerNode connects to the default outputNode, so now we'll have a complete playback path from
            //our file to the outputNode!
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: format)

            //let's play the file!
            //note: player must be attached first before scheduling a file to play
            player.scheduleFile(audioFile, at: nil, completionHandler: nil)
        } catch let error {
            print(error.localizedDescription)
        }
        
        //tap it to get the buffer data at playtime
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { (buffer, time) in
            //The tapBlock may be invoked on a thread other than the main thread. good, most likely we are not on main
            self.processAudioData(buffer: buffer)
        }

        //start playing the music!
        player.play()
    }
    
    func processAudioData(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else {return}
        let frames = buffer.frameLength
        
        // calculate loudness levels (rms and interpolation)
        let rmsValue = SignalProcessing.rms(data: channelData, frameLength: UInt(frames))
        let interpolatedResults = SignalProcessing.interpolate(current: rmsValue, previous: prevRMSValue)
        prevRMSValue = rmsValue
        
        //pass values to the audiovisualizer for the rendering
        for rms in interpolatedResults {
            audioVisualizerView.loudnessMagnitude = rms
        }
        
        // calculate fft
        let fftMagnitudes = SignalProcessing.fft(data: channelData, setup: fftSetup!)
        audioVisualizerView.frequencyVertices = fftMagnitudes
    }

}

