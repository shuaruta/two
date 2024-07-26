import SwiftUI
import AudioToolbox

struct SwiftUIView: View {
    @State private var targetPosition = CGSize.zero
    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var isGameActive = false
    @State private var isHovering = false

    var body: some View {
        VStack {
            Text("スコア: \(score)")
                .font(.largeTitle)
            
            Text("残り時間: \(timeRemaining)秒")
                .font(.title)
            
            ZStack {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 70, height: 70)
                    .position(x: 150 + targetPosition.width, y: 150 + targetPosition.height)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                targetPosition = value.translation
                            }
                            .onEnded { _ in
                                if isGameActive {
                                    score += 1
                                    moveTarget()
                                    playSystemSound(soundID: 1004)
                                }
                            }
                    )
                    .onHover { hovering in
                        isHovering = hovering
                    }
                    .overlay(
                        Circle()
                            .stroke(isHovering ? Color.blue : Color.clear, lineWidth: 4)
                            .frame(width: 70, height: 70)
                    )
            }
            .frame(width: 300, height: 300)
            .background(Color.gray.opacity(0.2))
            
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
        }
    }

    private func startGame() {
        isGameActive = true
        score = 0
        timeRemaining = 30
        moveTarget()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                endGame()
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
            height: CGFloat.random(in: -100...100)
        )
    }

    private func playSystemSound(soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
}

#Preview {
    SwiftUIView()
}
