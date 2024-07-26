import SwiftUI
import AudioToolbox

struct SwiftUIView: View {
    @State private var targetPosition = CGSize.zero
    @State private var ballPosition = CGSize.zero
    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var isGameActive = false
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
                    .frame(width: 70, height: 70)
                    .position(x: 150 + targetPosition.width, y: targetYPosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newWidth = value.translation.width
                                let newX = 150 + newWidth
                                if newX >= 35 && newX <= 265 {
                                    targetPosition.width = newWidth
                                }                            }
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
                        .frame(width: 50, height: 50)
                    .position(x: 150 + ballPosition.width, y: ballPosition.height)
                }
            }
            .frame(width: 300, height: 300)
            .background(Color.gray.opacity(0.2))
            .padding()
        }
    }

    private func startGame() {
        isGameActive = true
        score = 0
        timeRemaining = 30
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
                targetYPosition += 3
                if targetYPosition > 300 {
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
        playSystemSound(soundID: 1005) // ゲーム終了音
    }
    
    private func moveTarget() {
        targetPosition = CGSize(
            width: CGFloat.random(in: -100...100),
            height: 0
        )
    }
    
    private func moveBall() {
        ballPosition = CGSize(
            width: CGFloat.random(in: -100...100),
            height: CGFloat.random(in: 0...300)
        )
    }
    
    private func checkCollision() {
        let targetRect = CGRect(x: 150 + targetPosition.width - 35, y: targetYPosition - 35, width: 70, height: 70)
        let ballRect = CGRect(x: 150 + ballPosition.width - 25, y: ballPosition.height - 25, width: 50, height: 50)
        
        if targetRect.intersects(ballRect) {
            score += 1
            playSystemSound(soundID: 1004) // 衝突音
            moveBall()
        }
    }

    private func playSystemSound(soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
}

#Preview {
    SwiftUIView()
}
