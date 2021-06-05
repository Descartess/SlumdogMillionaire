//
//  SlumDogMillionaireTests.swift
//  SlumDogMillionaireTests
//
//  Created by Paul Nyondo on 03/06/2021.
//

import XCTest
import ComposableArchitecture

@testable import SlumDogMillionaire

class SlumDogMillionaireTests: XCTestCase {
    let scheduler = DispatchQueue.test

    func testStartingGame() {
        let scheduler = DispatchQueue.test
        let store = TestStore(initialState: AppState(),
                              reducer: appReducer,
                              environment: AppEnvironment(loadQuestions: { _ in Effect(value: testQuestionBank)},
                                                          bundle: Bundle(for: type(of: self)),
                                                          mainQueue: scheduler.eraseToAnyScheduler()))

        store.send(.loadGame)

        scheduler.advance(by: 1)

        store.receive(.startGame(.success(testQuestionBank))) {
            $0.levelState = testInitialLevelState
        }

        store.receive(.level(action: .timerTicked)) {
            $0.levelState?.answerPeriod = 59
        }

        store.assert( .send(.endGame) {
            $0.levelState = nil
        })
    }

    func testEndingGame() {
        let store = TestStore(initialState: AppState(levelState: testInitialLevelState),
                              reducer: appReducer,
                              environment: AppEnvironment(loadQuestions: { _ in Effect(value: testQuestionBank)},
                                                          bundle: Bundle(for: type(of: self)),
                                                          mainQueue: self.scheduler.eraseToAnyScheduler()))

        store.assert( .send(.endGame) {
            $0.levelState = nil
        })
    }

    func testAttemptCorrectAnswerToLevel() {
        let store = TestStore(initialState: AppState(levelState: testInitialLevelState),
                              reducer: appReducer,
                              environment: AppEnvironment(loadQuestions: { _ in Effect(value: testQuestionBank)},
                                                          bundle: Bundle(for: type(of: self)),
                                                          mainQueue: self.scheduler.eraseToAnyScheduler()))

        store.assert( .send(.level(action: .attempt(solution: 1))) {
            $0.levelState?.levelPassed = true
        })
    }

    func testAttemptWrongAnswerToLevel() {
        let store = TestStore(initialState: AppState(levelState: testInitialLevelState),
                              reducer: appReducer,
                              environment: AppEnvironment(loadQuestions: { _ in Effect(value: testQuestionBank)},
                                                          bundle: Bundle(for: type(of: self)),
                                                          mainQueue: self.scheduler.eraseToAnyScheduler()))

        store.assert( .send(.level(action: .attempt(solution: 2))) {
            $0.levelState?.levelPassed = false
        })
    }

    func testAdvanceToNextLevel() {
        let scheduler = DispatchQueue.test
        let store = TestStore(initialState: AppState(levelState: testInitialLevelState),
                              reducer: appReducer,
                              environment: AppEnvironment(loadQuestions: { _ in Effect(value: testQuestionBank)},
                                                          bundle: Bundle(for: type(of: self)),
                                                          mainQueue: scheduler.eraseToAnyScheduler()))
        store.assert(.send(.level(action: .next)) {
            $0.levelState?.levelPassed = nil
            $0.levelState?.currentLevel = testLevels[1]
            $0.levelState?.answerPeriod = 60
        })

        scheduler.advance(by: 1)

        store.receive(.level(action: .timerTicked)) {
            $0.levelState?.answerPeriod = 59
        }

        store.assert( .send(.endGame) {
            $0.levelState = nil
        })
    }
}
