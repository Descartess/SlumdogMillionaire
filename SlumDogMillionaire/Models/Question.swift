//
//  Question.swift
//  SlumDogMillionaire
//
//  Created by Paul Nyondo on 03/06/2021.
//

import Foundation
import ComposableArchitecture

struct Question: Decodable, Equatable {
    let level: Int
    let text: String
    let answers: [String]
    let solution: Int
}

struct QuestionResponseError: Equatable, Error {
    let description: String
}

struct QuestionResponse: Decodable {
    let questions: QuestionBank
}

typealias QuestionBank = [Question]

extension QuestionBank {
    static func load(from bundle: Bundle) -> Effect<QuestionBank, QuestionResponseError> {
        let decoder = JSONDecoder()

        guard
            let url = bundle.url(forResource: "questions", withExtension: "json")
        else {
            preconditionFailure("Question path must exist")
        }

        do {
            let data = try Data(contentsOf: url)
            let questionBank = try decoder.decode(QuestionResponse.self, from: data)
            return   Effect(value: questionBank.questions)
        } catch {
            return Effect(error: QuestionResponseError(description: "Decoding failed"))
        }
    }

    func getRandom(for level: Int) -> Question {
        guard
            let question = self.filter({ $0.level == level}).randomElement()
        else {
            preconditionFailure("Question must exist")
        }
        return question
    }
}


protocol QuestionLoader {
    func loadQuestionBank() -> Effect<QuestionBank, QuestionResponseError>
}


extension Bundle: QuestionLoader {
    func loadQuestionBank() -> Effect<QuestionBank, QuestionResponseError> {
        let decoder = JSONDecoder()

        guard
            let url = self.url(forResource: "questions", withExtension: "json")
        else {
            preconditionFailure("Question path must exist")
        }

        do {
            let data = try Data(contentsOf: url)
            let questionBank = try decoder.decode(QuestionResponse.self, from: data)
            return   Effect(value: questionBank.questions)
        } catch {
            return Effect(error: QuestionResponseError(description: "Decoding failed"))
        }
    }
}

struct OpenTriviaQuestionLoader: QuestionLoader {
    func loadQuestionBank() -> Effect<QuestionBank, QuestionResponseError> {
        let jsonDecoder = JSONDecoder()
        guard
            let url = URL(string: "https://opentdb.com/api.php?amount=15&type=multiple")
        else {
            preconditionFailure("URL must not be nil")
        }

        return URLSession.shared.dataTaskPublisher(for: url)
                .map { data, _ in data }
                .decode(type: OpenTriviaResponse.self, decoder: jsonDecoder)
                .mapError { QuestionResponseError(description: "Network error: \($0)") }
                .map({ $0.transform()})
                .eraseToEffect()
    }
}

