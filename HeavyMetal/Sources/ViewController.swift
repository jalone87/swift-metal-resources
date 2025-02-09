//
//  ViewController.swift
//  HeavyMetal
//
//  Created by Lorenzo Tognalini on 06.02.25.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        let metalCircleView = MetalCircleView()
        let metalCircleView = AudioVisualizerView()
        view.addSubview(metalCircleView)
        
        //constraining to window
        metalCircleView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        metalCircleView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        metalCircleView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        metalCircleView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }


}

