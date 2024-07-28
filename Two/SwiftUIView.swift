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

    @State private var targetXPosition: CGFloat = 0.0
    @State private var targetYPosition: CGFloat = 0.0
    @State private var ballPosition = CGSize.zero
    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var isGameActive = false
    @State private var gameTimer: Timer?
    @State private var movementTimer: Timer?
    @State private var isButtonDisabled = false
    @State private var ballColor = Color.green // ボールの色を管理する変数
    @State private var ballScale: CGFloat = 1.0 // ボールのスケールを管理する変数
    @State private var isCollisionProcessing = false // 衝突処理中かどうかを管理するフラグ

    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: targetSize, height: targetSize)
                    .position(x: targetInitialX + targetXPosition, y: targetYPosition)
                    .animation(.easeInOut(duration: 0.1), value: targetXPosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newX = value.location.x - targetInitialX
                                if newX < targetMinX - targetInitialX {
                                    targetXPosition = targetMinX - targetInitialX
                                } else if newX > targetMaxX - targetInitialX {
                                    targetXPosition = targetMaxX - targetInitialX
                                } else {
                                    targetXPosition = newX
                                }
                            }
                    )
                    .hoverEffect(.automatic)

                if isGameActive {
                    Circle()
                        .fill(ballColor)
                        .frame(width: ballSize, height: ballSize)
                        .scaleEffect(ballScale)
                        .position(x: targetInitialX + ballPosition.width, y: ballPosition.height)
                        .animation(.easeInOut(duration: 0.5), value: ballScale)
                        .hoverEffect(.automatic)
                        .offset(z: 10)
                }
            }
            .frame(width: gameAreaSize, height: gameAreaSize)
            .frame(depth: 10)
            .background(Color.gray.opacity(0.2))
            .padding()
 
            VStack {
                Button(isGameActive ? "ゲーム終了" : "ゲーム開始") {
                    if isGameActive {
                        endGame(playSound: true)
                    } else {
                        startGame()
                    }
                    disableButtonTemporarily()
                }
                .padding()
                .background(isGameActive ? Color.red : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isButtonDisabled)

                Text("スコア: \(score)")
                    .font(.largeTitle)
                    .padding()
                    .frame(width: 200, alignment: .leading) // 固定幅を設定
                
                Text("残り時間: \(timeRemaining)秒")
                    .font(.title)
                    .padding()
                    .frame(width: 200, alignment: .leading) // 固定幅を設定
            }

        }
            
    }

    private func startGame() {
        endGame(playSound: false) // 既存のゲームを終了してから新しいゲームを開始

        isGameActive = true
        score = 0
        timeRemaining = gameDuration
        targetYPosition = 0.0
        targetXPosition = 0.0
        moveTarget()
        moveBall()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                endGame(playSound: true)
            }
        }
        
        movementTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if isGameActive {
                withAnimation(targetYPosition > gameAreaSize ? nil : .easeInOut(duration: 0.1)) {
                    targetYPosition += targetSpeed
                }
                if targetYPosition > gameAreaSize {
                    targetYPosition = 0
                }
                checkCollision()
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func endGame(playSound: Bool) {
        isGameActive = false
        gameTimer?.invalidate()
        movementTimer?.invalidate()
        if playSound {
            playSystemSound(soundID: endGameSoundID) // ゲーム終了音
        }
    }
    
    private func moveTarget() {
        targetXPosition = CGFloat.random(in: randomRangeX)
        targetYPosition = 0
    }
    
    private func moveBall() {
        var newBallPosition: CGSize
        var attempts = 0
        let maxAttempts = 100

        repeat {
            newBallPosition = CGSize(
                width: CGFloat.random(in: randomRangeX),
                height: CGFloat.random(in: 0...gameAreaSize)
            )
            attempts += 1
        } while checkCollision(newBallPosition: newBallPosition) && attempts < maxAttempts

        ballPosition = newBallPosition
    }

    private func checkCollision(newBallPosition: CGSize) -> Bool {
        let targetRect = CGRect(
            x: targetInitialX + targetXPosition - targetSize / 2,
            y: targetYPosition - targetSize / 2,
            width: targetSize,
            height: targetSize
        )
        let ballCenter = CGPoint(
            x: targetInitialX + newBallPosition.width,
            y: newBallPosition.height
        )
        let ballRadius = ballSize / 2

        return rectIntersectsCircle(rect: targetRect, circleCenter: ballCenter, circleRadius: ballRadius)
    }

    private func checkCollision() {
        guard !isCollisionProcessing else { return } // 衝突処理中なら何もしない

        let targetRect = CGRect(
            x: targetInitialX + targetXPosition - targetSize / 2,
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
            isCollisionProcessing = true // 衝突処理中に設定
            score += 1
            playSystemSound(soundID: collisionSoundID) // 衝突音

            // ボールの色と大きさを変化させる
            ballColor = .yellow
            ballScale = 0.5
            
            // 少し遅延を加えてからボールを移動し、再表示する
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                moveBall()
                ballColor = .green
                ballScale = 1.0
                isCollisionProcessing = false // 衝突処理中を解除
            }
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

    private func disableButtonTemporarily() {
        isButtonDisabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isButtonDisabled = false
        }
    }
}

#Preview {
    SwiftUIView()
}
