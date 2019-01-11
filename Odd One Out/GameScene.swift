//
//  GameScene.swift
//  Odd One Out
//
//  Created by Markus Varner on 1/6/19.
//  Copyright © 2019 Markus Varner. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var level = 1
    let scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    var startTime = 0.0
    var timeLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
    var isGameRunning = true
    
    override func didMove(to view: SKView) {
        //Setup Background
        let background = SKSpriteNode(imageNamed: "background-leaves")
        background.name = "background"
        background.zPosition = 0
        background.size.height = self.size.height
        addChild(background)
        scoreLabel.position = CGPoint(x: 0, y: 500)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.fontSize = 70.0
        scoreLabel.zPosition = 1
        background.addChild(scoreLabel)
        timeLabel.position = CGPoint(x: 0, y: 400)
        timeLabel.fontSize = 50.0
        timeLabel.fontColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        timeLabel.horizontalAlignmentMode = .center
        timeLabel.zPosition = 1
        background.addChild(timeLabel)
        score = 0
        //setup grid
        createGrid()
        createLevel()
        //Add Background music
        let music = SKAudioNode(fileNamed: "night-cave")
        background.addChild(music)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameRunning else {return}
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        guard let tapped = tappedNodes.first else {return}
        if tapped.name == "correct" {
            correctAnswer(node: tapped)
        } else if tapped.name == "wrong" {
            wrongAnswer(node: tapped)
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameRunning {
            if startTime == 0 {
                startTime = currentTime
            }
            let timePassed = currentTime - startTime
            let remainingTime = Int(ceil(10 - timePassed))
            timeLabel.text = "\(remainingTime)"
            timeLabel.alpha = 1
            //If user runs out of time, Inform them the game is over
            if remainingTime <= 0 {
                isGameRunning = false
                let gameOver = SKSpriteNode(imageNamed: "gameOver2")
                gameOver.zPosition = 100
                addChild(gameOver)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if let scene = GameScene(fileNamed: "GameScene") {
                        scene.scaleMode = .aspectFill
                        self.view?.presentScene(scene)
                    }
                }
            }
        } else {
            timeLabel.alpha = 0
        }
    }
    
    func correctAnswer(node: SKNode) {
        isUserInteractionEnabled = false
        //reset game count down
        startTime = 0
        //play correct sound
        run(SKAction.playSoundFileNamed("correct-1", waitForCompletion: false))
        //increase user score
        score += 1
        //place sparks in the position of the correct answer
        if let sparks = SKEmitterNode(fileNamed: "Sparks") {
            sparks.position = node.position
            addChild(sparks)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                sparks.removeFromParent()
                self.level += 1
                self.createLevel()
            }
        }
    }
    
    func wrongAnswer(node: SKNode) {
        run(SKAction.playSoundFileNamed("wrong-3", waitForCompletion: false))
        score = 0
        let wrong = SKSpriteNode(imageNamed: "wrong")
        wrong.position = node.position
        wrong.zPosition = 5
        addChild(wrong)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            wrong.removeFromParent()
            self.level = 1
            self.createLevel()
        }
    }
    
    func createGrid() {
        let xOffset = -245
        let yOffset = -420
        for row in 0..<12 {
            for col in  0..<8 {
                let item = SKSpriteNode(imageNamed: "elephant")
                item.position = CGPoint(x: xOffset + (col * 70), y: yOffset + (row * 70))
                addChild(item)
            }
        }
    }
    
    func createLevel(){
        isUserInteractionEnabled = true
        var itemsToShow = (level * 2) + 1
        //this ensures our grid never has more than 96 items
        itemsToShow = min(itemsToShow, 96)
        //find all child nodes without the name background
        let items = self.children.filter {$0.name != "background"}
        //shuffle the nodes
        let shuffled = items.shuffled() as! [SKSpriteNode]
        for item in shuffled {
            //set all item nodes to be invisible
            item.alpha = 0
        }
        
        let animals = ["elephant", "giraffe", "hippo", "monkey", "panda", "parrot", "penguin", "pig", "rabbit", "snake"]
        var shuffledAnimals = animals.shuffled()
        let correct = shuffledAnimals.removeLast()
        var showAnimals = [String]()
        var placingAnimal = 0
        var numUsed = 0
        for _ in 1 ..< itemsToShow {
            //mark that we've used this animal
            numUsed += 1
            showAnimals.append(shuffledAnimals[placingAnimal])
            //if we used this animal twice move on to the next one
            if numUsed == 2 {
                numUsed = 0
                placingAnimal += 1
            }
            
            //if we have gone through all the animals restart
            if placingAnimal == shuffledAnimals.count {
                placingAnimal = 0
            }
        }
        
        for (index, animal) in showAnimals.enumerated() {
            //pull out the matching item
            let item = shuffled[index]
            //assign the correct texture
            item.texture = SKTexture(imageNamed: animal)
            //show it
            item.alpha = 1
            //mark it as wrong
            item.name = "wrong"
        }
        
        shuffled.last?.texture = SKTexture(imageNamed: correct)
        shuffled.last?.alpha = 1
        shuffled.last?.name = "correct"
        
    }
    
    
}
