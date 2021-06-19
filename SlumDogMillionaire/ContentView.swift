//
//  ContentView.swift
//  SlumDogMillionaire
//
//  Created by Paul Nyondo on 03/06/2021.
//

import SwiftUI
import ComposableArchitecture

enum AppAction: Equatable {
    case startGame(Result<QuestionBank, QuestionResponseError>)
    case endGame
    case loadGame
    case level(action: LevelAction)
}

struct AppEnvironment {
    var loadQuestions: () -> Effect<QuestionBank, QuestionResponseError>
    var bundle = Bundle.main
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

struct AppState: Equatable {
    var gameLoadError = false
    var levelState: LevelState?
    var isLoading = false
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine( Reducer { state, action, environment in
    switch action {
        case let .startGame(.success(questions)):
            let gameLevels = Level.build(from: questions)
            state.isLoading = false
            state.levelState = LevelState(currentLevel: gameLevels[0], levels: gameLevels)
            return Effect.timer(id: TimerId(),
                                every: 1,
                                tolerance: .zero,
                                on: environment.mainQueue)
                .map {_ in  AppAction.level(action: .timerTicked) }
        case .startGame(.failure):
            state.gameLoadError =  true
            return .none
        case .endGame:
            state.levelState = nil
            return Effect.cancel(id: TimerId())
        case .loadGame:
            state.isLoading = true
            return environment.loadQuestions()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(AppAction.startGame)
    case .level(action: let action):
        let x = Color.secondary
        return .none
    }
},
levelReducer.optional().pullback(state: \.levelState,
                                 action: /AppAction.level(action:),
                                 environment: { _ in LevelEnvironment(mainQueue: .main) })
)

struct ContentView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        IfLetStore(
            self.store.scope(state: \.levelState),
            then: { store in
                LevelView(store: store)
            },
            else: {
                HomeView(store: store)
            })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
            ContentView(store: Store(initialState: AppState(),
                                     reducer: appReducer,
                                     environment: AppEnvironment(
                                        loadQuestions: Bundle.main.loadQuestionBank,
                                        mainQueue: .main
                                     )
                )
            )
    }
}
