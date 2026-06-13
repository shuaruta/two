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

        resetTargets()
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
        for index in model.targets.indices {
            if model.targets[index].yPosition > model.settings.gameAreaSize {
                model.targets[index].yPosition = 0
            } else {
                model.targets[index].yPosition += model.settings.targetSpeed
            }
        }
    }

    private func resetTargets() {
        for index in model.targets.indices {
            model.targets[index].xPosition = GameModel.targetInitialXOffsets[index]
            // 2つ目以降は半周期ずらして単調な動きを避ける
            model.targets[index].yPosition = model.settings.gameAreaSize / 2 * CGFloat(index)
        }
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
        } while overlapsAnyTarget(ballPosition: newBallPosition) && attempts < maxAttempts

        model.ballPosition = newBallPosition
        model.ballTargetIndex = Int.random(in: 0..<model.targets.count)
        model.ballColor = GameModel.targetColors[model.ballTargetIndex]
    }

    private func targetRect(at index: Int) -> CGRect {
        CGRect(
            x: model.settings.targetInitialX + model.targets[index].xPosition - model.settings.targetSize / 2,
            y: model.targets[index].yPosition - model.settings.targetSize / 2,
            width: model.settings.targetSize,
            height: model.settings.targetSize
        )
    }

    private func overlapsAnyTarget(ballPosition: CGSize) -> Bool {
        let ballCenter = CGPoint(
            x: model.settings.targetInitialX + ballPosition.width,
            y: ballPosition.height
        )
        let ballRadius = model.settings.ballSize / 2

        return model.targets.indices.contains { index in
            rectIntersectsCircle(rect: targetRect(at: index), circleCenter: ballCenter, circleRadius: ballRadius)
        }
    }

    private func checkCollision() {
        guard !model.isCollisionProcessing else { return }

        let ballCenter = CGPoint(
            x: model.settings.targetInitialX + model.ballPosition.width,
            y: model.ballPosition.height
        )
        let ballRadius = model.settings.ballSize / 2

        // 得点になるのはボールと同じ色のターゲットに当てたときだけ
        let scoringRect = targetRect(at: model.ballTargetIndex)

        if rectIntersectsCircle(rect: scoringRect, circleCenter: ballCenter, circleRadius: ballRadius) {
            model.isCollisionProcessing = true
            model.score += 1
            playSystemSound(soundID: model.settings.collisionSoundID)

            model.ballColor = .yellow
            model.ballScale = 0.5

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }

                self.moveBall()
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

    func updateTargetXPosition(index: Int, basedOn locationX: CGFloat) {
        let newX = locationX - model.settings.targetInitialX
        let minX = model.settings.targetMinX - model.settings.targetInitialX
        let maxX = model.settings.targetMaxX - model.settings.targetInitialX

        model.targets[index].xPosition = min(max(newX, minX), maxX)
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
