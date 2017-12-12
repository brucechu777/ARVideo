//
//  ViewController.swift
//  ARVideo
//
//  Created by bruce on 2017/12/12.
//  Copyright © 2017年 bruce. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // 音乐播放器
    
    private var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        loadAnimation()
        
        // 载入音乐
        loadMusic()
    }
    
    // 载入AR
    func loadAnimation() {
        let sceneCharacter = SCNScene(named: "art.scnassets/Robot Hip Hop Dance.dae")!
        
        let parentNode = SCNNode()
        
        for child in sceneCharacter.rootNode.childNodes {
            parentNode.addChildNode(child)
        }
        parentNode.position = SCNVector3(0,-1,-2)
        parentNode.scale = SCNVector3(0.009,0.009,0.009)
        
        sceneView.scene.rootNode.addChildNode(parentNode)
    }
    
    // 载入音乐
    func loadMusic() {
        let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: "TFBOYS - 青春修炼手册 - live", ofType: "mp3")!)
        try! audioPlayer = AVAudioPlayer(contentsOf: alertSound)
        audioPlayer!.prepareToPlay()
        audioPlayer!.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
}
