//
//  OpenTriviaResponse.swift
//  SlumDogMillionaire
//
//  Created by Paul Nyondo on 18/06/2021.
//

import Foundation

// MARK: - OpenTriviaResponse
struct OpenTriviaResponse: Codable {
    let responseCode: Int
    let results: [OpenTriviaQuestion]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }

    func transform() -> QuestionBank {
        results.enumerated().map { $0.element.transform(level: $0.offset) }
    }
}

// MARK: - OpenTriviaQuestion
struct OpenTriviaQuestion: Codable {
    let difficulty: Difficulty
    let question: String
    let correctAnswer: String
    var incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case difficulty, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }

    func transform(level: Int) -> Question {
        var answers = self.incorrectAnswers
        answers.shuffle()
        let solution = Int.random(in: 0...incorrectAnswers.endIndex)
        answers.insert(correctAnswer, at: solution)

        return Question(level: level, text: question, answers: answers, solution: solution)
    }
}

enum Difficulty: String, Codable {
    case easy = "easy"
    case hard = "hard"
    case medium = "medium"
}

