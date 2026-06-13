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
            gameDuration: 40,
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
            gameDuration: 40,
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
            gameDuration: 40,
            collisionSoundID: 1004,
            endGameSoundID: 1005
        )
    }
    
    
    struct TargetState {
        var xPosition: CGFloat = 0.0
        var yPosition: CGFloat = 0.0
    }

    static let targetColors: [Color] = [.blue, .red]

    static let maxLevel = 3

    static let clearScore = 10

    static func initialXOffsets(targetCount: Int) -> [CGFloat] {
        targetCount == 1 ? [0] : [-75, 75]
    }

    var score: Int = 0

    var level: Int = 1

    var levelScore: Int = 0

    var isGameCleared: Bool = false

    var timeRemaining: Int

    var isGameActive: Bool = false

    var targets: [TargetState] = [TargetState()]

    var ballPosition = CGSize.zero

    var ballTargetIndex: Int = 0

    var ballColor: Color = .green

    var ballScale: CGFloat = 1.0

    // レベル1: 1個1色 / レベル2: 2個1色 / レベル3: 2個2色
    var targetCount: Int {
        level == 1 ? 1 : 2
    }

    var requiresColorMatch: Bool {
        level >= GameModel.maxLevel
    }

    func targetColor(at index: Int) -> Color {
        requiresColorMatch ? GameModel.targetColors[index] : GameModel.targetColors[0]
    }
    
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
