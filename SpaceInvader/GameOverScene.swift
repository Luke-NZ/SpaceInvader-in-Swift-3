//
//  GameOverScene.swift
//  SpaceInvader
//
//  Created by 李远 on 17/09/16.
//  Copyright © 2016 Luke. All rights reserved.
//

import UIKit
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, won: Bool) {
        super.init(size:size)
        
        self.backgroundColor = SKColor.black
        
        var message = String()
        
        if won {
            message = "You Win!"
        } else {
            message = "Game Over"
        }
        
        let label = SKLabelNode(fontNamed: "DamascusBold")
        label.text = message
        label.fontColor = SKColor.white
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        
        addChild(label)
        
        run(SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.run {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let scene = GameScene(size: size)
            self.view?.presentScene(scene, transition: transition)
            }]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
