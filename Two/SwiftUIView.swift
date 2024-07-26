import SwiftUI
import AudioToolbox

struct SwiftUIView: View {
    private let targetSize: CGFloat = 70
    private let ballSize: CGFloat = 50
    private let gameAreaSize: CGFloat = 300
    private let targetInitialX: CGFloat = 150
    private let targetMinX: CGFloat = 35
    private let targetMaxX: CGFloat = 265
    private let targetSpeed: CGFloat = 5
    private let gameDuration: Int = 30
    private let collisionSoundID: SystemSoundID = 1004
    private let endGameSoundID: SystemSoundID = 1005
    private var randomRangeX: ClosedRange<CGFloat> {
        let halfGameArea = gameAreaSize / 2
        return -halfGameArea...halfGameArea
    }

    @State private var targetPosition = CGSize.zero
    @State private var ballPosition = CGSize.zero
    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var isGameActive = false
    @State private var isHovering = false
    @State private var targetYPosition: CGFloat = 0.0

    var body: some View {
        VStack {
            Button(isGameActive ? "ゲーム終了" : "ゲーム開始") {
                if isGameActive {
                    endGame()
                } else {
                    startGame()
                }
            }
            .padding()
            .background(isGameActive ? Color.red : Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            Text("スコア: \(score)")
                .font(.largeTitle)
                .padding()
            
            Text("残り時間: \(timeRemaining)秒")
                .font(.title)
                .padding()
            
            ZStack {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: targetSize, height: targetSize)
                    .position(x: targetInitialX + targetPosition.width, y: targetYPosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newX = value.location.x - targetInitialX
                                if newX < targetMinX - targetInitialX {
                                    targetPosition.width = targetMinX - targetInitialX
                                } else if newX > targetMaxX - targetInitialX {
                                    targetPosition.width = targetMaxX - targetInitialX
                                } else {
                                    targetPosition.width = newX
                                }
                            }
                            .onEnded { _ in
                                if isGameActive {
                                    checkCollision()
                                }
                            }
                    )
                    .hoverEffect(.automatic)
                
                if isGameActive {
                    Circle()
                        .fill(Color.green)
                        .frame(width: ballSize, height: ballSize)
                        .position(x: targetInitialX + ballPosition.width, y: ballPosition.height)
                }
            }
            .frame(width: gameAreaSize, height: gameAreaSize)
            .background(Color.gray.opacity(0.2))
            .padding()
        }
    }

    private func startGame() {
        isGameActive = true
        score = 0
        timeRemaining = gameDuration
        targetYPosition = 0.0
        targetPosition = CGSize.zero
        moveTarget()
        moveBall()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                endGame()
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if isGameActive {
                targetYPosition += targetSpeed
                if targetYPosition > gameAreaSize {
                    targetYPosition = 0
                }
                checkCollision()
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func endGame() {
        isGameActive = false
        playSystemSound(soundID: endGameSoundID) // ゲーム終了音
    }
    
    private func moveTarget() {
        targetPosition = CGSize(
            width: CGFloat.random(in: randomRangeX),
            height: 0
        )
    }
    
    private func moveBall() {
        ballPosition = CGSize(
            width: CGFloat.random(in: randomRangeX),
            height: CGFloat.random(in: 0...gameAreaSize)
        )
    }
    
    private func checkCollision() {
        let targetRect = CGRect(
            x: targetInitialX + targetPosition.width - targetSize / 2,
            y: targetYPosition - targetSize / 2,
            width: targetSize,
            height: targetSize
        )
        let ballCenter = CGPoint(
            x: targetInitialX + ballPosition.width,
            y: ballPosition.height
        )
        let ballRadius = ballSize / 2
        
        if rectIntersectsCircle(rect: targetRect, circleCenter: ballCenter, circleRadius: ballRadius) {
            score += 1
            playSystemSound(soundID: collisionSoundID) // 衝突音
            moveBall()
        }
    }
    
    private func rectIntersectsCircle(rect: CGRect, circleCenter: CGPoint, circleRadius: CGFloat) -> Bool {
        // 円の中心から矩形の最も近い点までの距離を計算し、その距離が円の半径より小さいかどうかを確認
        let closestX = max(rect.minX, min(circleCenter.x, rect.maxX))
        let closestY = max(rect.minY, min(circleCenter.y, rect.maxY))
        
        let distanceX = circleCenter.x - closestX
        let distanceY = circleCenter.y - closestY
        
        let distanceSquared = (distanceX * distanceX) + (distanceY * distanceY)
        return distanceSquared < (circleRadius * circleRadius)
    }

    private func playSystemSound(soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
}

#Preview {
    SwiftUIView()
}
