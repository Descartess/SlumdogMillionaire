//
//  Level.swift
//  SlumDogMillionaire
//
//  Created by Paul Nyondo on 04/06/2021.
//

import SwiftUI
import ComposableArchitecture

struct TimerId: Hashable {}

enum LevelAction: Equatable {
    case next
    case timerTicked
    case attempt(solution: Int)
}

struct LevelState: Equatable {
    var currentLevel: Level
    var mostRecentFixLevel: Level?
    var levels: [Level]
    var levelPassed: Bool?
    var answerPeriod: Int = 60
}

struct LevelEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let levelReducer = Reducer<LevelState, LevelAction, LevelEnvironment> { state, action, environment in
    switch action {
    case .next:
        let currentLevel = state.currentLevel
        let mostRecentFixLevel = state.mostRecentFixLevel

        state.levelPassed = nil
        state.mostRecentFixLevel = currentLevel.isFixLevel ? currentLevel : mostRecentFixLevel

        guard
            currentLevel != state.levels.last
        else { return .none }

        state.currentLevel = state.levels[currentLevel.id+1]
        state.answerPeriod = 60
        return Effect.timer(id: TimerId(),
                            every: 1,
                            tolerance: .zero,
                            on: environment.mainQueue)
            .map { _ in .timerTicked }
    case .attempt(solution: let solution):
        state.levelPassed = state.currentLevel.question.solution == solution
       return Effect.cancel(id: TimerId())
    case .timerTicked:
        guard
            state.answerPeriod > 0
        else {
            state.levelPassed = false
            return Effect.cancel(id: TimerId())
        }
        state.answerPeriod -= 1
        return .none
    }
}

struct LevelView: View {
    let store: Store<LevelState, AppAction>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                Text("Level \(viewStore.state.currentLevel.id)")
                    .font(.largeTitle)
                Text("Prize $ \(viewStore.state.currentLevel.prize)")
                    .font(.title3)
                    .foregroundColor(Color.gray)
                Spacer()

                LazyVStack {
                    Text("\(viewStore.state.currentLevel.question.text)")
                        .font(.title2)
                        .padding()
                        .multilineTextAlignment(.center)
                    ForEach(Array(viewStore.state.currentLevel.question.answers.enumerated()), id: \.element) { index, answer in
                        Button(answer) {
                            viewStore.send(.level(action: .attempt(solution: index)))
                        }
                        .padding()
                        .clipShape(Capsule())
                        .disabled(viewStore.levelPassed != nil )
                    }
                }

                Text("\(viewStore.answerPeriod)")
                    .font(.title3)
                    .hidden(viewStore.levelPassed != nil)

                Text("You win $\(viewStore.mostRecentFixLevel?.prize ?? 0)")
                    .hidden(viewStore.levelPassed != false)

                Button("Continue") {
                    viewStore.send(.level(action: .next))
                }
                .hidden(viewStore.levelPassed != true)
                .disabled( viewStore.currentLevel == viewStore.levels.last)
                Spacer()
                HStack {
                    Button("50-50") {}
                        .padding()
                    Button("Ask audience") {}
                        .padding()
                    Button("Phone Friend") {}
                        .padding()
                }.hidden(viewStore.levelPassed != nil)

                Button("End Game") {
                    viewStore.send(.endGame)
                }
            }
        }
    }
}
