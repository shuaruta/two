//
//
//

import SwiftUI

struct GameModel {
    
    struct Settings {
        var targetSize: CGFloat
        var ballSize: CGFloat
        var gameAreaSize: CGFloat
        var targetInitialX: CGFloat
        var targetMinX: CGFloat
        var targetMaxX: CGFloat
        var targetSpeed: CGFloat
        var gameDuration: Int
        var collisionSoundID: UInt32
        var endGameSoundID: UInt32
        
        static let easy = Settings(
            targetSize: 80,
            ballSize: 60,
            gameAreaSize: 300,
            targetInitialX: 150,
            targetMinX: 35,
            targetMaxX: 265,
            targetSpeed: 3,
            gameDuration: 45,
            collisionSoundID: 1004,
            endGameSoundID: 1005
        )
        
        static let normal = Settings(
            targetSize: 70,
            ballSize: 50,
            gameAreaSize: 300,
            targetInitialX: 150,
            targetMinX: 35,
            targetMaxX: 265,
            targetSpeed: 5,
            gameDuration: 30,
            collisionSoundID: 1004,
            endGameSoundID: 1005
        )
        
        static let hard = Settings(
            targetSize: 60,
            ballSize: 40,
            gameAreaSize: 300,
            targetInitialX: 150,
            targetMinX: 35,
            targetMaxX: 265,
            targetSpeed: 8,
            gameDuration: 20,
            collisionSoundID: 1004,
            endGameSoundID: 1005
        )
    }
    
    
    var score: Int = 0
    
    var timeRemaining: Int
    
    var isGameActive: Bool = false
    
    var targetXPosition: CGFloat = 0.0
    
    var targetYPosition: CGFloat = 0.0
    
    var ballPosition = CGSize.zero
    
    var ballColor: Color = .green
    
    var ballScale: CGFloat = 1.0
    
    var isCollisionProcessing: Bool = false
    
    var settings: Settings
    
    
    var randomRangeX: ClosedRange<CGFloat> {
        let halfGameArea = settings.gameAreaSize / 2
        return -halfGameArea...halfGameArea
    }
    
    
    init(difficulty: Difficulty = .normal) {
        switch difficulty {
        case .easy:
            settings = .easy
        case .normal:
            settings = .normal
        case .hard:
            settings = .hard
        }
        timeRemaining = settings.gameDuration
    }
}

enum Difficulty {
    case easy, normal, hard
}
