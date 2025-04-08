//
//
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        HStack {
            GameAreaView(viewModel: viewModel)
                .padding(120)
            
            GameControlsView(viewModel: viewModel)
        }
    }
}

struct GameAreaView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.blue)
                .frame(width: viewModel.model.settings.targetSize, height: viewModel.model.settings.targetSize)
                .position(
                    x: viewModel.model.settings.targetInitialX + viewModel.model.targetXPosition,
                    y: viewModel.model.targetYPosition
                )
                .animation(.easeInOut(duration: 0.1), value: viewModel.model.targetXPosition)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            viewModel.updateTargetXPosition(basedOn: value.location.x)
                        }
                )
                .hoverEffect(.automatic)
            
            if viewModel.model.isGameActive {
                Circle()
                    .fill(viewModel.model.ballColor)
                    .frame(width: viewModel.model.settings.ballSize, height: viewModel.model.settings.ballSize)
                    .scaleEffect(viewModel.model.ballScale)
                    .position(
                        x: viewModel.model.settings.targetInitialX + viewModel.model.ballPosition.width,
                        y: viewModel.model.ballPosition.height
                    )
                    .animation(.easeInOut(duration: 0.5), value: viewModel.model.ballScale)
                    .hoverEffect(.automatic)
                    .offset(z: 10)
            }
        }
        .frame(width: viewModel.model.settings.gameAreaSize, height: viewModel.model.settings.gameAreaSize)
        .frame(depth: 10)
        .background(Color.gray.opacity(0.2))
    }
}

struct GameControlsView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack {
            Button(viewModel.model.isGameActive ? "ゲーム終了" : "ゲーム開始") {
                viewModel.handleGameControlButtonTap()
            }
            .padding()
            .background(viewModel.model.isGameActive ? Color.red : Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(viewModel.isButtonDisabled)
            
            Text("スコア: \(viewModel.model.score)")
                .font(.largeTitle)
                .padding()
                .frame(width: 200, alignment: .leading)
            
            Text("残り時間: \(viewModel.model.timeRemaining)秒")
                .font(.title)
                .padding()
                .frame(width: 200, alignment: .leading)
            
            if !viewModel.model.isGameActive {
                Picker("難易度", selection: $viewModel.selectedDifficulty) {
                    Text("1").tag(Difficulty.easy)
                    Text("2").tag(Difficulty.normal)
                    Text("3").tag(Difficulty.hard)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
        }
    }
}

#Preview {
    GameView()
}
