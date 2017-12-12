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
import ARVideoKit
import Photos

class ViewController: UIViewController, ARSCNViewDelegate, RecordARDelegate {
    func recorder(didEndRecording path: URL, with noError: Bool) {
        
    }
    
    func recorder(didFailRecording error: Error?, and status: String) {
        
    }
    
    func recorder(willEnterBackground status: RecordARStatus) {
        if status == .recording {
            recorder?.stopAndExport()
        }
    }
    

    @IBOutlet var sceneView: ARSCNView!
    
    // 录像按钮
    @IBOutlet weak var recordBtn: UIButton!
    
    // 录像
    var recorder:RecordAR?
    let recordingQueue = DispatchQueue(label: "recordingThread", attributes: .concurrent)
    let caprturingQueue = DispatchQueue(label: "capturingThread", attributes: .concurrent)
    // 音乐播放器
    private var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Initialize ARVideoKit recorder
        recorder = RecordAR(ARSceneKit: sceneView)
        
        /*----👇---- ARVideoKit Configuration ----👇----*/
        
        // Set the recorder's delegate
        recorder?.delegate = self
        
        recordBtn.setTitle("录像", for: .normal)
        
        // 载入AR
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
    
    
    // 触发录像
    @IBAction func record(_ sender: Any) {
        //Record
        if recorder?.status == .readyToRecord {
            recordBtn.setTitle("停止", for: .normal)
            recordingQueue.async {
                self.recorder?.record()
            }
        }else if recorder?.status == .recording {
            recordBtn.setTitle("录像", for: .normal)
            recorder?.stop() { path in
                self.recorder?.export(video: path) { saved, status in
                    DispatchQueue.main.sync {
                        self.exportMessage(success: saved, status: status)
                    }
                }
            }
        }
    }
    
    // 录像后
    func exportMessage(success: Bool, status:PHAuthorizationStatus) {
        if success {
            let alert = UIAlertController(title: "Exported", message: "Media exported to camera roll successfully!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Awesome", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if status == .denied || status == .restricted || status == .notDetermined {
            let errorView = UIAlertController(title: "😅", message: "Please allow access to the photo library in order to save this media file.", preferredStyle: .alert)
            let settingsBtn = UIAlertAction(title: "Open Settings", style: .cancel) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        })
                    } else {
                        UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                    }
                }
            }
            errorView.addAction(UIAlertAction(title: "Later", style: UIAlertActionStyle.default, handler: {
                (UIAlertAction)in
            }))
            errorView.addAction(settingsBtn)
            self.present(errorView, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Exporting Failed", message: "There was an error while exporting your media file.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        // Prepare the recorder with sessions configuration
        recorder?.prepare(configuration)
    }
}
