//
//  GameScene.swift
//  Solo Mission
//
//  Created by UE App Devs on 1/31/20.
//
//  Copyright © 2020 Evan Tall. All rights reserved.
//

import SpriteKit

let restartLabel = SKLabelNode(fontNamed: "The Bold Font")
var gameScore = 0


class GameScene: SKScene, SKPhysicsContactDelegate {
    //declaring the player spaceship
    let player = SKSpriteNode(imageNamed: "spaceship")

   
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var levelNumber = 1
    var livesNumber = 3
    
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    let versionLabel = SKLabelNode(fontNamed: "The Bold Font")
    

    enum gameState{
        case preGame
        case inGame
        case afterGame
    }
    
    var currentGameState = gameState.preGame
    
//    Creating the physics behind the game, assigning each category to a number with binary code
    struct PhysicsCategories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 //1
        static let Bullet: UInt32 = 0b10 //2
        static let Enemy: UInt32 = 0b100 //4
        static let ExtraLife: UInt32 = 0b1000
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 4294967295)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
    
    var gameArea: CGRect
    //Setting up game dimensions
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 19.5/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    
    //setting up the wallpaper and images for the game
    override func didMove(to view: SKView) {
        
        gameScore = 0
        
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0...1{
            
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.anchorPoint = CGPoint(x: 0.5, y: 0)
        background.position = CGPoint(x: self.size.width/2,
                                      y: self.size.height * CGFloat(i))
        background.zPosition = 0
        background.name = "Background"
        self.addChild(background)
        }
        
       /* let pauseButton = SKSpriteNode(imageNamed: "PauseButton")
        pauseButton.size = self.size
        pauseButton.position = CGPoint(x:self.size.width/2, y:self.size.height/2*5)
        pauseButton.zPosition = 100
        self.addChild(pauseButton)
       */
       
        player.setScale(0.5)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.2, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 50
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.8, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height * 0.85, duration: 0.3)
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 90
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel )
        
        versionLabel.text = "Version: 0.3"
        versionLabel.fontSize = 50
        versionLabel.fontColor = SKColor.white
        versionLabel.zPosition = 1
        versionLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/10)
        self.addChild(versionLabel)
        
       
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        
    }
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 600.0
    
    override func update(_ currentTime: TimeInterval){
        if lastUpdateTime == 0{
            lastUpdateTime = currentTime
        }
        else{
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        
        self.enumerateChildNodes(withName: "Background"){
            background, stop in
            
            background.position.y -= amountToMoveBackground
            
            if background.position.y < -self.size.height{
                background.position.y += self.size.height*2
            }
        }
        
    }
    
    func startGame(){
        
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        versionLabel.run(deleteSequence)
        
        let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        //let spawnNewLife = SKAction.run(spawnExtraLife)
        let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
        player.run(startGameSequence)
    }
    
    func loseALife(){
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        if livesNumber == 0{
            runGameOver()
        }

    }
    
    func addALife(){
             livesNumber += 1
             livesLabel.text = "Lives: \(livesNumber)"
             let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
             let scaleDown = SKAction.scale(to: 1, duration: 0.2)
             let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
             livesLabel.run(scaleSequence)
             
             if livesNumber == 0{
                 runGameOver()
             }

         }
    
    func addScore(){
        
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 5 || gameScore == 10 || gameScore == 15 || gameScore == 20 || gameScore == 30 || gameScore == 35 || gameScore == 40 || gameScore == 45 || gameScore == 50 || gameScore == 80 {
            startNewLevel()
        }
        
        
    }
    
    
    func runGameOver(){
        
        currentGameState = gameState.afterGame
        
        self.removeAllActions()
        
        self.enumerateChildNodes(withName: "Bullet"){
            bullet, stop in
            bullet.removeAllActions()
            
        }
        
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
        
        
    }
    
    
    func changeScene(){
        
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: (0.5))
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
        
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        //If player has hit enemy
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy{
          
            if body1.node != nil {
            spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            if body2.node != nil {
            spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
            
        }
        
        //If bullet hits extraLife
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.ExtraLife{
            addALife()
            
            if body2.node != nil{
                         if body2.node!.position.x > self.size.width{
                             return
                         }
                         else{
                         spawnExplosion(spawnPosition: body2.node!.position)
                         }
                     }

                       body1.node?.removeFromParent()
                       body2.node?.removeFromParent()
            
        }
        
        
        //If bullet hits enemy
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy{
            addScore()
            
  
          if body2.node != nil{
              if body2.node!.position.y > self.size.height{
                  return
              }
              else{
              spawnExplosion(spawnPosition: body2.node!.position)
              }
          }

            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
        }
        
        
        
    }
    
    func spawnExplosion(spawnPosition: CGPoint){
        
        let explosion = SKSpriteNode(imageNamed: "explosition")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
        
    }
    
    func startNewLevel(){
        
        levelNumber += 1
        spawnExtraLife()
        
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber {
        case 1: levelDuration = 4.0
        case 2: levelDuration = 3.5
        case 3: levelDuration = 3.0
        case 4: levelDuration = 2.0
        case 5: levelDuration = 1.8
        case 6: levelDuration = 1.5
        case 7: levelDuration = 1.0
        case 8: levelDuration = 0.8
        case 9: levelDuration = 0.75
        default:
            levelDuration = 0.69
            print("cannot find level info")
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let SpawnSequence = SKAction.sequence([waitToSpawn,spawn])
        let spawnForever = SKAction.repeatForever(SpawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
        
    }
    
    //fire bullet method
    func fireBullet() {
        // setting up the bullet and the size and location of it
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy | PhysicsCategories.ExtraLife
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    //Spawn enemy method
    func spawnEnemy(){
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "Enemy"
        enemy.setScale(0.5)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 2)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        
        if currentGameState == gameState.inGame{
            enemy.run(enemySequence)
        }
    
    }
    func spawnExtraLife(){
        let randomYStart = random(min:gameArea.minY, max: gameArea.maxY)
        let randomYEnd = random(min: gameArea.minY, max: gameArea.maxY)
        
        let startPointLife = CGPoint(x: -self.size.width * 0.2, y: randomYStart)
        let endPointLife = CGPoint(x: self.size.width * 1.2, y: randomYEnd)
        
        let extraLife = SKSpriteNode(imageNamed: "Extra Life")
        extraLife.name = "ExtraLife"
        extraLife.setScale(0.5)
        extraLife.position = startPointLife
        extraLife.zPosition = 2
        extraLife.physicsBody = SKPhysicsBody(rectangleOf: extraLife.size)
        extraLife.physicsBody!.affectedByGravity = false
        extraLife.physicsBody!.categoryBitMask = PhysicsCategories.ExtraLife
        extraLife.physicsBody!.collisionBitMask = PhysicsCategories.None
        extraLife.physicsBody!.contactTestBitMask = PhysicsCategories.Bullet
        self.addChild(extraLife)
        
        let moveExtraLife = SKAction.move(to: endPointLife, duration: 2.5)
        let deleteLife = SKAction.removeFromParent()
        let lifeSequence = SKAction.sequence([moveExtraLife, deleteLife])
        extraLife.run(lifeSequence)
        
        
        
        
        
        
        
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.preGame{
            startGame()
        }
        else if currentGameState == gameState.inGame{
            fireBullet()
        }
    
    }
    
    // Controls and math for moving the player ship
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch =  touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            if currentGameState == gameState.inGame{
                player.position.x += amountDragged
                player.position.y = self.size.height * 0.2
            }
            
            
            

            // Too far right
            if player.position.x > gameArea.maxX - player.size.width/2 {
                player.position.x = gameArea.maxX - player.size.width/2
            }
            // Too far left
            if player.position.x < gameArea.minX + player.size.width/2 {
                player.position.x = gameArea.minX + player.size.width/2
            }
            
            
        }
    }
    
}
