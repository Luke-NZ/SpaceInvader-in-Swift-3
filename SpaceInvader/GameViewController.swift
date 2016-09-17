//
//  GameViewController.swift
//  SpaceInvader
//
//  Created by 李远 on 14/09/16.
//  Copyright (c) 2016 Luke. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {

    var backgroundMusicPlayer: AVAudioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }*/
    }

    override func viewWillLayoutSubviews() {
        
        let bgMusicURL:URL = Bundle.main.url(forResource: "bgmusic", withExtension: "mp3")!
        
        backgroundMusicPlayer = try! AVAudioPlayer(contentsOf: bgMusicURL)
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
        
        let skView = self.view as! SKView

        let scene = GameScene(size:skView.bounds.size) // Converted from Swift 1.0:    let scene = GameScene.sceneWithSize(skView.bounds.size)

        skView.showsFPS = true
        skView.showsNodeCount = true

        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
    
    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
