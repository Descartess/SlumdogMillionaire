//
//  SlumDogMillionaireApp.swift
//  SlumDogMillionaire
//
//  Created by Paul Nyondo on 03/06/2021.
//

import SwiftUI
import ComposableArchitecture

@main
struct SlumDogMillionaireApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(initialState: AppState(),
                                     reducer: appReducer,
                                     environment: AppEnvironment(
                                        loadQuestions: OpenTriviaQuestionLoader().loadQuestionBank,
                                        mainQueue: .main
                                     )
                )
            )
        }
    }
}
