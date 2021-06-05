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

struct QuestionResponseError: Equatable, Error {}

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
            return Effect(error: QuestionResponseError())
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
