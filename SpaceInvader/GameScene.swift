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
    var lastYieldTimeInterval = TimeInterval()
    var lastUpdateTimeInterval = TimeInterval()
    var aliensDestroyed = 0
    
    let alienCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    
    override func didMove(to view: SKView) {
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
        self.backgroundColor = SKColor.black
        player = SKSpriteNode(imageNamed: "shuttle")
        
        player.position = CGPoint(x: self.frame.size.width/2, y: player.size.height/2 + 20)
        
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
    }
    
    func addAlien() {
        
        let alien = SKSpriteNode(imageNamed: "alien")
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        
        let minX = alien.size.width/2
        let maxX = frame.size.width - alien.size.width/2
        let rangeX = maxX - minX
        let position = CGFloat(arc4random()).truncatingRemainder(dividingBy: rangeX) + minX
        
        alien.position = CGPoint(x: position, y: frame.size.height+alien.size.height)
        
        addChild(alien)
        
        let minDuration = 2
        let maxDuration = 4
        let rangeDuration = maxDuration - minDuration
        let duration = Int(arc4random()) % Int(rangeDuration) + Int(minDuration)
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -alien.size.height), duration: TimeInterval(duration))) // move alien from top to bottom of the screen within duration.
        
        actionArray.append(SKAction.run {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: transition)
        })
        
        actionArray.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actionArray))
    }
    
    func updateWithTimeSinceLastUpdate(_ timeSinceLastUpdate:CFTimeInterval) {
        
        lastYieldTimeInterval += timeSinceLastUpdate
        
        // add another alien every lastYieldTimeInterval(1 second)
        if lastYieldTimeInterval > 1 {
            lastYieldTimeInterval = 0 // reset lastYieldTimeInterval
            addAlien()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        let timeSinceLastUpdate = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        
//        if timeSinceLastUpdate > 1 {
//            
//            timeSinceLastUpdate = 1/60
//            lastUpdateTimeInterval = currentTime
//        }
        
        updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        let touch = touches.first! as UITouch
        let location = touch.location(in: self)
        
        let torpedo = SKSpriteNode(imageNamed: "torpedo")
        torpedo.position = player.position
        
        torpedo.physicsBody = SKPhysicsBody(circleOfRadius: torpedo.size.width/2)
        torpedo.physicsBody?.isDynamic = true
        torpedo.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedo.physicsBody?.contactTestBitMask = alienCategory
        torpedo.physicsBody?.collisionBitMask = 0
        torpedo.physicsBody?.usesPreciseCollisionDetection = true
        
        let offset = vecSub(a: location, b: torpedo.position)
        
        // if touch location is below the starting location of torpedo(i.e. wrong direction), then exit the function.
        if offset.y < 0 {
            return
        }
        
        addChild(torpedo)
        
        let direction = vecNormalize(a: offset)
        
        let shotLength = vecMult(a: direction, b: 1500)
        
        let finalDestination = vecAdd(a: shotLength, b: torpedo.position)
        
        let velocity = CGFloat(568/1)
        let moveDuration = self.size.width / velocity
        
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: finalDestination, duration:TimeInterval( moveDuration)))
        actionArray.append(SKAction.removeFromParent())
        
        torpedo.run(SKAction.sequence(actionArray))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody : SKPhysicsBody
        var secondBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 {
            torpedoDidCollideWithAlien(torpedo: firstBody.node as! SKSpriteNode, alien: secondBody.node as! SKSpriteNode)
        }
    }
    
    func torpedoDidCollideWithAlien(torpedo: SKSpriteNode, alien:SKSpriteNode) {
        
        print("Hit")
        
        torpedo.removeFromParent()
        alien.removeFromParent()
        
        aliensDestroyed += 1
        
        if aliensDestroyed > 10 {
            
            //Transition to Game Success
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: transition)
        }
    }
    
    func vecAdd(a:CGPoint, b:CGPoint) -> CGPoint {
        
        return CGPoint(x: a.x + b.x, y: a.y + b.y)
    }
    
    func vecSub(a:CGPoint, b:CGPoint) -> CGPoint {
        
        return CGPoint(x: a.x - b.x, y: a.y - b.y)
    }
    
    func vecMult(a:CGPoint, b:CGFloat) -> CGPoint {
        
        return CGPoint(x: a.x * b, y: a.y * b)
    }
    
    func vecLength(a:CGPoint) -> CGFloat {
        
        return CGFloat(sqrtf(CFloat(a.x) * CFloat(a.x) + CFloat(a.y) * CFloat(a.y)))
    }
    
    func vecNormalize(a:CGPoint) -> CGPoint {
        
        let length = vecLength(a: a)
        return CGPoint(x: a.x / length, y: a.y / length)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.location(in: self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotate(byAngle: CGFloat(M_PI), duration:1)
            
            sprite.run(SKAction.repeatForever(action))
            
            self.addChild(sprite)
        }
    }*/
    
}
