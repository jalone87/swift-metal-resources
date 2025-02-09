//
//  ViewController.swift
//  HeavyMetal
//
//  Created by Lorenzo Tognalini on 06.02.25.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let metalCircleView = MetalCircleView()
//        view.addSubview(metalCircleView)
//
//        //constraining to window
//        metalCircleView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        metalCircleView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        metalCircleView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        metalCircleView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//    }
    
    var engine : AVAudioEngine!
    var audioVisualizerView: AudioVisualizerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let audioVisualizerView = AudioVisualizerView()
        view.addSubview(audioVisualizerView)
        
        //constraining to window
        audioVisualizerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        audioVisualizerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        audioVisualizerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        audioVisualizerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        setupAudio()
    }
    
    func setupAudio() {
        
        /* Setup & Start Engine */
        
        //initialize it
        engine = AVAudioEngine()
        
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

        //start playing the music!
        player.play()
    }

}

