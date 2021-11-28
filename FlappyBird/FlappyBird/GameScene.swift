//
//  GameScene.swift
//  FlappyBird
//
//  Created by Hristoslav-PC on 11/21/21.
//

import SpriteKit
import GameplayKit

struct CollisionBitMask {
    //we use these bitmasks to see if:
    //we belong to a certain category(categoryBitMask)
    //we have collided with somebody(collisionBitMask)
    //if we have collided - getting notified that we have collided with a given object - the one we set in the (contactTestBitMask) property
    /*for example - the bird belongs to the Bird category - so we take the bird bit mask(1), it can collide with the wall or with the ground - so we set the collision bit mask to both of them - ground | wall, the same goes for the contactTestBitMask - ground | wall*/
    static let Bird : UInt32 = 1
    static let Ground : UInt32 = 2
    static let Wall : UInt32 = 3
}

class GameScene: SKScene {
    
    var background = SKSpriteNode(imageNamed: "Flappy-Bird-Background")
    var ground = SKSpriteNode(imageNamed: "Flappy-Bird-Ground")
    var bird = SKSpriteNode(imageNamed: "Flappy-Bird-Skin")
    var wallPair = SKNode()
    var moveAndRemoveAction = SKAction()
    var gameStarted = Bool()
    
    override func didMove(to view: SKView) {
        /*removing the helloLabel from the gamescene as we cannot remove it manually from the file using a VM because xcode shuts down unexpectedly(lol)
         P.S.: piracy ftw*/
        let helloLabel = self.childNode(withName: "helloLabel") as? SKLabelNode
        helloLabel?.removeFromParent()
        
        createBackground()
        createGround()
        createBird()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //begin falling only when we start touching the screen
        bird.physicsBody?.affectedByGravity = true
        bird.run(SKAction.moveTo(x: self.frame.midX, duration: 1.0))
        if gameStarted == false {
            gameStarted = true
            
            var moveWalls = SKAction()
            var removeWalls = SKAction()
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let spawnWalls = SKAction.run({
                () in
                
                moveWalls = SKAction.moveBy(x: -distance, y: 0, duration: 2 * distance)
                removeWalls = SKAction.removeFromParent()
                self.createWallPair()
            })
            
            let spawnWallsDelay = SKAction.wait(forDuration: 3.0)
            let spawnWallsSequence = SKAction.sequence([spawnWalls, spawnWallsDelay])
            let spawnWallsDelayForever = SKAction.repeatForever(spawnWallsSequence)
            self.run(spawnWallsDelayForever)
            
            moveAndRemoveAction = SKAction.sequence([moveWalls, removeWalls])
            
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx:0, dy:90))
            self.wallPair.run(moveAndRemoveAction)
        }
        else {
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let moveWalls = SKAction.moveBy(x: -distance, y: 0, duration: 0.008 * distance)
            let removeWalls = SKAction.removeFromParent()
            moveAndRemoveAction = SKAction.sequence([moveWalls, removeWalls])
            
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 190))
            self.wallPair.run(moveAndRemoveAction)
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func createBackground() {
        background = SKSpriteNode(imageNamed: "Flappy-Bird-Background")
        background.setScale(2)
        background.zPosition = 1
        self.addChild(background)
    }
    
    func createGround() {
        ground.position = CGPoint(x: self.frame.minX, y: self.frame.minY)
        ground.zPosition = 2
        ground.setScale(2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.categoryBitMask = CollisionBitMask.Ground
        ground.physicsBody?.collisionBitMask = CollisionBitMask.Bird
        ground.physicsBody?.contactTestBitMask = CollisionBitMask.Bird
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false
        self.addChild(ground)
    }
    
    func createBird() {
        bird.position.x = self.frame.minX
        bird.zPosition = 2
        bird.setScale(0.3)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.frame.height / 2)
        bird.physicsBody?.categoryBitMask = CollisionBitMask.Bird
        bird.physicsBody?.collisionBitMask = CollisionBitMask.Ground | CollisionBitMask.Wall
        bird.physicsBody?.contactTestBitMask = CollisionBitMask.Ground | CollisionBitMask.Wall
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = true
        self.addChild(bird)
    }
    
    func createWallPair() {
        wallPair = SKNode()
        let topWall = SKSpriteNode(imageNamed: "Flappy-Bird-Wall")
        let bottomWall = SKSpriteNode(imageNamed: "Flappy-Bird-Wall")
        topWall.position = CGPoint(x: self.frame.maxX / 2, y: self.frame.maxY)
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = CollisionBitMask.Wall
        topWall.physicsBody?.collisionBitMask = CollisionBitMask.Bird
        topWall.physicsBody?.contactTestBitMask = CollisionBitMask.Bird
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        bottomWall.position = CGPoint(x: self.frame.maxX / 2, y: self.frame.minY)
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        bottomWall.physicsBody?.categoryBitMask = CollisionBitMask.Wall
        bottomWall.physicsBody?.collisionBitMask = CollisionBitMask.Bird
        bottomWall.physicsBody?.contactTestBitMask = CollisionBitMask.Bird
        bottomWall.physicsBody?.isDynamic = false
        bottomWall.physicsBody?.affectedByGravity = false
        
        topWall.position = CGPoint(x: self.frame.maxX / 2, y: self.frame.maxY)
        
        bottomWall.position = CGPoint(x: self.frame.maxX / 2, y: self.frame.minY)
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        wallPair.zPosition = 3
        wallPair.position.y = CGFloat.random(in: -200...200)
        self.addChild(wallPair)
    }
}
