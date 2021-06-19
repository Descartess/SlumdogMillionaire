//
//  HomeView.swift
//  SlumDogMillionaire
//
//  Created by Paul Nyondo on 04/06/2021.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                Text("Slumdog Millionaire")
                    .font(.title)
                    .padding()
                Button("Start Game") {
                    withAnimation {
                        viewStore.send(.loadGame)
                    }
                }.disabled(viewStore.isLoading)
                ProgressView()
                    .transition(AnyTransition.scale(scale: 10)) //.move(edge: .bottom))
                    .hidden(!viewStore.isLoading)
            }
        }
    }
}
