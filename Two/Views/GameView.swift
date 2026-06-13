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
        .onAppear {
            // デバッグ用: シミュレータ検証でゲームを自動開始する
            if ProcessInfo.processInfo.arguments.contains("-autostart") {
                viewModel.startGame()
            }
        }
    }
}

struct GameAreaView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            ForEach(viewModel.model.targets.indices, id: \.self) { index in
                Rectangle()
                    .fill(viewModel.model.targetColor(at: index))
                    .frame(width: viewModel.model.settings.targetSize, height: viewModel.model.settings.targetSize)
                    .position(
                        x: viewModel.model.settings.targetInitialX + viewModel.model.targets[index].xPosition,
                        y: viewModel.model.targets[index].yPosition
                    )
                    .animation(.easeInOut(duration: 0.1), value: viewModel.model.targets[index].xPosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                viewModel.updateTargetXPosition(index: index, basedOn: value.location.x)
                            }
                    )
                    .hoverEffect(.automatic)
            }
            
            if viewModel.model.isGameActive {
                Circle()
                    .fill(viewModel.model.ballColor)
                    .padding(4)
                    .background(Circle().fill(Color.white))
                    .frame(width: viewModel.model.settings.ballSize, height: viewModel.model.settings.ballSize)
                    .scaleEffect(viewModel.model.ballScale)
                    .position(
                        x: viewModel.model.settings.targetInitialX + viewModel.model.ballPosition.width,
                        y: viewModel.model.ballPosition.height
                    )
                    .animation(.easeInOut(duration: 0.5), value: viewModel.model.ballScale)
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
            
            Text("レベル: \(viewModel.model.level) / \(GameModel.maxLevel)")
                .font(.title)
                .padding()
                .frame(width: 200, alignment: .leading)

            Text("スコア: \(viewModel.model.score)")
                .font(.largeTitle)
                .padding()
                .frame(width: 200, alignment: .leading)
            
            Text("残り時間: \(viewModel.model.timeRemaining)秒")
                .font(.title)
                .padding()
                .frame(width: 200, alignment: .leading)
            
            if viewModel.model.isGameCleared {
                Text("クリア!")
                    .font(.largeTitle)
                    .foregroundColor(.yellow)
                    .padding()
            }

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
