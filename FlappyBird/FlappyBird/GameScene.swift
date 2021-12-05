//
//  GameScene.swift
//  FlappyBird
//
//  Created by Hristoslav-PC on 11/21/21.
//

import SpriteKit
import GameplayKit
import AVFoundation

struct CollisionBitMask {
    //we use these bitmasks to see if:
    //we belong to a certain category(categoryBitMask)
    //we have collided with somebody(collisionBitMask)
    //if we have collided - getting notified that we have collided with a given object - the one we set in the (contactTestBitMask) property
    /*for example - the bird belongs to the Bird category - so we take the bird bit mask(1), it can collide with the wall or with the ground - so we set the collision bit mask to both of them - ground | wall, the same goes for the contactTestBitMask - ground | wall*/
    static let Bird : UInt32 = 1
    static let Ground : UInt32 = 2
    static let Wall : UInt32 = 3
    static let MiddleOfWallPair : UInt32 = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var background = SKSpriteNode(imageNamed: "Flappy-Bird-Background")
    var ground = SKSpriteNode(imageNamed: "Flappy-Bird-Ground")
    var bird = SKSpriteNode(imageNamed: "Flappy-Bird-Skin")
    var wallPair = SKNode()
    var moveAndRemoveAction = SKAction()
    var gameStarted = Bool()
    var score = Int()
    var scoreLabel = SKLabelNode()
    var isDead = Bool()
    var restartButton = SKSpriteNode(imageNamed: "Flappy-Bird-Restart-Button")
    var audioPlayer = AVAudioPlayer()
    
    override func didMove(to view: SKView) {
        /*removing the helloLabel from the gamescene as we cannot remove it manually from the file using a VM because xcode shuts down unexpectedly(lol)
         P.S.: piracy ftw*/
        let helloLabel = self.childNode(withName: "helloLabel") as? SKLabelNode
        helloLabel?.removeFromParent()
        
        self.physicsWorld.contactDelegate = self
        
        createMap()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //begin falling only when we start touching the screen
        bird.physicsBody?.affectedByGravity = true
        if gameStarted == false {
            
            gameStarted = true
            
            if !isDead {
                bird.run(SKAction.moveTo(x: self.frame.midX, duration: 1.0))
                
                playSong()
                
                var moveWalls = SKAction()
                var removeWalls = SKAction()
                let distance = CGFloat(self.frame.width + wallPair.frame.width)
                let spawnWalls = SKAction.run({
                    () in
                    
                    if !self.isDead {
                        moveWalls = SKAction.moveBy(x: -distance, y: 0, duration: 2 * distance)
                        removeWalls = SKAction.removeFromParent()
                        self.createWallPair()
                    }
                })
                
                let spawnWallsDelay = SKAction.wait(forDuration: 1.5)
                let spawnWallsSequence = SKAction.sequence([spawnWalls, spawnWallsDelay])
                let spawnWallsDelayForever = SKAction.repeatForever(spawnWallsSequence)
                self.run(spawnWallsDelayForever)
                
                moveAndRemoveAction = SKAction.sequence([moveWalls, removeWalls])
                
                bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bird.physicsBody?.applyImpulse(CGVector(dx:0, dy:90))
                self.wallPair.run(moveAndRemoveAction)
            }
        }
        else {
            
            if !isDead {
                let distance = CGFloat(self.frame.width + wallPair.frame.width)
                let moveWalls = SKAction.moveBy(x: -distance, y: 0, duration: 0.008 * distance)
                let removeWalls = SKAction.removeFromParent()
                moveAndRemoveAction = SKAction.sequence([moveWalls, removeWalls])
                
                bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 190))
                self.wallPair.run(moveAndRemoveAction)
            }
            
            for touch in touches {
                let locationOfTouch = touch.location(in: self)
                
                if isDead {
                    if restartButton.contains(locationOfTouch) {
                        restartMap()
                    }
                }
            }
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        changeScore(contact)
        
        tryDying(contact)
    }
    
    func createMap() {
        createBackground()
        createGround()
        createBird()
        createScore()
    }
    
    func restartMap() {
        self.removeAllChildren()
        self.removeAllActions()
        isDead = false
        gameStarted = false
        score = 0
        createMap()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if !isDead {
            let endlesslyMoveWallsAction = SKAction.run({
                () in
                self.endlesslyMoveWalls()
            })
            let delay = SKAction.wait(forDuration: 3.0)
            let removeWalls = SKAction.removeFromParent()
            let sequence = SKAction.sequence([endlesslyMoveWallsAction, delay, removeWalls])
            self.wallPair.run(sequence)
        }
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
        bird.position = CGPoint(x: self.frame.minX, y: self.frame.midY)
        bird.zPosition = 2
        bird.setScale(0.3)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.frame.height / 2)
        bird.physicsBody?.categoryBitMask = CollisionBitMask.Bird
        bird.physicsBody?.collisionBitMask = CollisionBitMask.Ground | CollisionBitMask.Wall
        bird.physicsBody?.contactTestBitMask = CollisionBitMask.Ground | CollisionBitMask.Wall | CollisionBitMask.MiddleOfWallPair
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = true
        bird.zRotation = 0.0
        self.addChild(bird)
    }
    
    func createWallPair() {
        wallPair = SKNode()
        let topWall = SKSpriteNode(imageNamed: "Flappy-Bird-Wall")
        let bottomWall = SKSpriteNode(imageNamed: "Flappy-Bird-Wall")
        topWall.position = CGPoint(x: self.frame.maxX / 1.1, y: self.frame.maxY + 100)
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = CollisionBitMask.Wall
        topWall.physicsBody?.collisionBitMask = CollisionBitMask.Bird
        topWall.physicsBody?.contactTestBitMask = CollisionBitMask.Bird
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        bottomWall.position = CGPoint(x: self.frame.maxX / 1.1, y: self.frame.minY - 100)
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        bottomWall.physicsBody?.categoryBitMask = CollisionBitMask.Wall
        bottomWall.physicsBody?.collisionBitMask = CollisionBitMask.Bird
        bottomWall.physicsBody?.contactTestBitMask = CollisionBitMask.Bird
        bottomWall.physicsBody?.isDynamic = false
        bottomWall.physicsBody?.affectedByGravity = false
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        wallPair.zPosition = 3
        wallPair.position.y = CGFloat.random(in: -200...200)
        wallPair.name = "wallPair"
        
        let middleOfWallPair = SKSpriteNode()
        middleOfWallPair.size = CGSize(width: 50, height: self.frame.height / 2)
        middleOfWallPair.position = CGPoint(x: self.frame.maxX / 1.1, y: wallPair.position.y / 2)
        middleOfWallPair.physicsBody = SKPhysicsBody(rectangleOf: middleOfWallPair.size)
        middleOfWallPair.physicsBody?.affectedByGravity = false
        middleOfWallPair.physicsBody?.isDynamic = false
        middleOfWallPair.physicsBody?.categoryBitMask = CollisionBitMask.MiddleOfWallPair
        middleOfWallPair.physicsBody?.collisionBitMask = 0
        middleOfWallPair.physicsBody?.contactTestBitMask = CollisionBitMask.Bird
        
        wallPair.addChild(middleOfWallPair)
        
        self.addChild(wallPair)
    }
    
    func endlesslyMoveWalls(){
        if !isDead {
            self.enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                node.position.x -= 9
                if node.position.x < -(self.scene?.size.width)! {
                    node.position.x += (self.scene?.size.width)! * 3
                }
             }))
        }
    }
    
    func createScore() {
        scoreLabel.text = "\(score)"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY / 1.5)
        scoreLabel.zPosition = 5
        scoreLabel.fontSize = 85
        self.addChild(scoreLabel)
    }
    
    func changeScore(_ contact: SKPhysicsContact) {
        if !isDead {
            if (contact.bodyA.categoryBitMask == CollisionBitMask.MiddleOfWallPair && contact.bodyB.categoryBitMask == CollisionBitMask.Bird) ||
                (contact.bodyA.categoryBitMask == CollisionBitMask.Bird && contact.bodyB.categoryBitMask == CollisionBitMask.MiddleOfWallPair) {
                score = score + 1
                scoreLabel.text = "\(score)"
            }
        }
    }
    
    func tryDying(_ contact: SKPhysicsContact) {
        if ((contact.bodyA.categoryBitMask == CollisionBitMask.Bird && contact.bodyB.categoryBitMask == CollisionBitMask.Ground)
        || (contact.bodyA.categoryBitMask == CollisionBitMask.Ground && contact.bodyB.categoryBitMask == CollisionBitMask.Bird))
            || ((contact.bodyA.categoryBitMask == CollisionBitMask.Bird && contact.bodyB.categoryBitMask == CollisionBitMask.Wall)
                || (contact.bodyA.categoryBitMask == CollisionBitMask.Wall && contact.bodyB.categoryBitMask == CollisionBitMask.Bird))
        {
            isDead = true
            createRestartButton()
            audioPlayer.stop()
        }
    }
    
    func createRestartButton() {
        restartButton.removeFromParent()
        restartButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        restartButton.zPosition = 6
        self.addChild(restartButton)
        restartButton.run(SKAction.scale(to: 1.0, duration: 1.0))
    }
    
    func playSong() {
        let song = Bundle.main.path(forResource: "Isyan Tetick - Patlamaya Devam", ofType: "mp3")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: song!))
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback,
                                                            mode: AVAudioSession.Mode.default,
                                                            options: [AVAudioSession.CategoryOptions.mixWithOthers])
            audioPlayer.play()
        }
        catch {
            print("An error occured when trying to find the song!")
        }
    }
}
