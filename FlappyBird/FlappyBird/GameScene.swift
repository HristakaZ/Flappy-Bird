//
//  GameScene.swift
//  FlappyBird
//
//  Created by Hristoslav-PC on 11/21/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var background = SKSpriteNode(imageNamed: "Flappy-Bird-Background")
    var ground = SKSpriteNode(imageNamed: "Flappy-Bird-Ground")
    var bird = SKSpriteNode(imageNamed: "Flappy-Bird-Skin")
    var topWall = SKSpriteNode(imageNamed: "Flappy-Bird-Wall")
    var bottomWall = SKSpriteNode(imageNamed: "Flappy-Bird-Wall")
    var wallPair = SKNode()
    
    override func didMove(to view: SKView) {
        /*removing the helloLabel from the gamescene as we cannot remove it manually from the file using a VM because xcode shuts down unexpectedly(lol)
         P.S.: piracy ftw*/
        let helloLabel = self.childNode(withName: "helloLabel") as? SKLabelNode
        helloLabel?.removeFromParent()
        
        background.setScale(2)
        background.zPosition = 1
        self.addChild(background)
        
        ground.position = CGPoint(x: self.frame.minX, y: self.frame.minY)
        ground.zPosition = 2
        ground.setScale(2)
        self.addChild(ground)
        
        bird.zPosition = 2
        bird.setScale(0.3)
        self.addChild(bird)
        
        topWall.position = CGPoint(x: self.frame.maxX / 2, y: self.frame.maxY)
        
        bottomWall.position = CGPoint(x: self.frame.maxX / 2, y: self.frame.minY)
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        wallPair.zPosition = 3
        self.addChild(wallPair)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
