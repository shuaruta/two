//
//
//

import SwiftUI
import AudioToolbox
import Combine

class GameViewModel: ObservableObject {
    @Published private(set) var model: GameModel
    
    @Published var selectedDifficulty: Difficulty {
        didSet {
            model = GameModel(difficulty: selectedDifficulty)
        }
    }
    
    @Published var isButtonDisabled = false
    
    private var gameTimer: Timer?
    private var movementTimer: Timer?
    
    init(difficulty: Difficulty = .normal) {
        self.selectedDifficulty = difficulty
        self.model = GameModel(difficulty: difficulty)
    }
    
    func startGame() {
        endGame(playSound: false)
        
        model.isGameActive = true
        model.score = 0
        model.timeRemaining = model.settings.gameDuration
        model.targetYPosition = 0.0
        model.targetXPosition = 0.0
        
        moveTarget()
        moveBall()
        
        setupTimers()
    }
    
    func endGame(playSound: Bool) {
        model.isGameActive = false
        gameTimer?.invalidate()
        movementTimer?.invalidate()
        
        if playSound {
            playSystemSound(soundID: model.settings.endGameSoundID)
        }
    }
    
    private func setupTimers() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            if self.model.timeRemaining > 0 {
                self.model.timeRemaining -= 1
            } else {
                timer.invalidate()
                self.endGame(playSound: true)
            }
        }
        
        movementTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self, self.model.isGameActive else {
                timer.invalidate()
                return
            }
            
            self.updateTargetPosition()
            self.checkCollision()
        }
    }
    
    private func updateTargetPosition() {
        if model.targetYPosition > model.settings.gameAreaSize {
            model.targetYPosition = 0
        } else {
            model.targetYPosition += model.settings.targetSpeed
        }
    }
    
    private func moveTarget() {
        model.targetXPosition = CGFloat.random(in: model.randomRangeX)
        model.targetYPosition = 0
    }
    
    private func moveBall() {
        var newBallPosition: CGSize
        var attempts = 0
        let maxAttempts = 100
        
        repeat {
            newBallPosition = CGSize(
                width: CGFloat.random(in: model.randomRangeX),
                height: CGFloat.random(in: 0...model.settings.gameAreaSize)
            )
            attempts += 1
        } while checkCollision(newBallPosition: newBallPosition) && attempts < maxAttempts
        
        model.ballPosition = newBallPosition
    }
    
    private func checkCollision(newBallPosition: CGSize) -> Bool {
        let targetRect = CGRect(
            x: model.settings.targetInitialX + model.targetXPosition - model.settings.targetSize / 2,
            y: model.targetYPosition - model.settings.targetSize / 2,
            width: model.settings.targetSize,
            height: model.settings.targetSize
        )
        
        let ballCenter = CGPoint(
            x: model.settings.targetInitialX + newBallPosition.width,
            y: newBallPosition.height
        )
        
        let ballRadius = model.settings.ballSize / 2
        
        return rectIntersectsCircle(rect: targetRect, circleCenter: ballCenter, circleRadius: ballRadius)
    }
    
    private func checkCollision() {
        guard !model.isCollisionProcessing else { return }
        
        let targetRect = CGRect(
            x: model.settings.targetInitialX + model.targetXPosition - model.settings.targetSize / 2,
            y: model.targetYPosition - model.settings.targetSize / 2,
            width: model.settings.targetSize,
            height: model.settings.targetSize
        )
        
        let ballCenter = CGPoint(
            x: model.settings.targetInitialX + model.ballPosition.width,
            y: model.ballPosition.height
        )
        
        let ballRadius = model.settings.ballSize / 2
        
        if rectIntersectsCircle(rect: targetRect, circleCenter: ballCenter, circleRadius: ballRadius) {
            model.isCollisionProcessing = true
            model.score += 1
            playSystemSound(soundID: model.settings.collisionSoundID)
            
            model.ballColor = .yellow
            model.ballScale = 0.5
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                
                self.moveBall()
                self.model.ballColor = .green
                self.model.ballScale = 1.0
                self.model.isCollisionProcessing = false
            }
        }
    }
    
    private func rectIntersectsCircle(rect: CGRect, circleCenter: CGPoint, circleRadius: CGFloat) -> Bool {
        let closestX = max(rect.minX, min(circleCenter.x, rect.maxX))
        let closestY = max(rect.minY, min(circleCenter.y, rect.maxY))
        
        let distanceX = circleCenter.x - closestX
        let distanceY = circleCenter.y - closestY
        
        let distanceSquared = (distanceX * distanceX) + (distanceY * distanceY)
        return distanceSquared < (circleRadius * circleRadius)
    }
    
    private func playSystemSound(soundID: UInt32) {
        AudioServicesPlaySystemSound(soundID)
    }

    func updateTargetXPosition(basedOn locationX: CGFloat) {
        let newX = locationX - model.settings.targetInitialX
        let minX = model.settings.targetMinX - model.settings.targetInitialX
        let maxX = model.settings.targetMaxX - model.settings.targetInitialX

        if newX < minX {
            model.targetXPosition = minX
        } else if newX > maxX {
            model.targetXPosition = maxX
        } else {
            model.targetXPosition = newX
        }
    }
    
    func disableButtonTemporarily() {
        isButtonDisabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isButtonDisabled = false
        }
    }
    
    func handleGameControlButtonTap() {
        if model.isGameActive {
            endGame(playSound: true)
        } else {
            startGame()
        }
        disableButtonTemporarily()
    }
}
