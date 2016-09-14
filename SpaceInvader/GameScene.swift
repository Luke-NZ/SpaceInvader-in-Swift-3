//
//  GameScene.swift
//  SpaceInvader
//
//  Created by 李远 on 14/09/16.
//  Copyright (c) 2016 Luke. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player = SKSpriteNode()
    var lastYieldTimeInterval = NSTimeInterval()
    var lastUpdateTimeInterval = NSTimeInterval()
    var aliensDestroyed = 0
    
    let alienCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!"
//        myLabel.fontSize = 45
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
//        
//        self.addChild(myLabel)
    }
    
    override init(size:CGSize) {
        super.init(size:size)
        self.backgroundColor = SKColor.blackColor()
        player = SKSpriteNode(imageNamed: "shuttle")
        
        player.position = CGPointMake(self.frame.size.width/2, player.size.height/2 + 20)
        
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        
    }
    
    func addAlien() {
        
        let alien = SKSpriteNode(imageNamed: "alien")
        alien.physicsBody = SKPhysicsBody(rectangleOfSize: alien.size)
        alien.physicsBody?.dynamic = true
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        
        let minX = alien.size.width/2
        let maxX = frame.size.width - alien.size.width/2
        let rangeX = maxX - minX
        let position = CGFloat(arc4random()) % rangeX + minX
        
        alien.position = CGPointMake(position, frame.size.height+alien.size.height)
        
        addChild(alien)
        
        let minDuration = 2
        let maxDuration = 4
        let rangeDuration = maxDuration - minDuration
        let duration = Int(arc4random()) % Int(rangeDuration) + Int(minDuration)
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.moveTo(CGPointMake(position, -alien.size.height), duration: NSTimeInterval(duration))) // move alien from top to bottom of the screen within duration.
        actionArray.append(SKAction.removeFromParent())
        
        alien.runAction(SKAction.sequence(actionArray))
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate:CFTimeInterval) {
        
        lastYieldTimeInterval += timeSinceLastUpdate
        
        // add another alien every lastYieldTimeInterval(1 second)
        if lastYieldTimeInterval > 1 {
            lastYieldTimeInterval = 0 // reset lastYieldTimeInterval
            addAlien()
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        var timeSinceLastUpdate = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        
        if timeSinceLastUpdate > 1 {
            
            timeSinceLastUpdate = 1/60
            lastUpdateTimeInterval = currentTime
        }
        
        updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
}
