//
//  Level.swift
//  SlumDogMillionaire
//
//  Created by Paul Nyondo on 03/06/2021.
//

import Foundation

struct Level: Identifiable, Equatable {
    let id: Int
    let prize: Int
    let isFixLevel: Bool
    let question: Question

    static func build(from questions: QuestionBank) -> [Level] {
        return [
            Level(id: 0, prize: 50, isFixLevel: false, question: questions.getRandom(for: 0)),
            Level(id: 1, prize: 100, isFixLevel: false, question: questions.getRandom(for: 1)),
            Level(id: 2, prize: 200, isFixLevel: false, question: questions.getRandom(for: 2)),
            Level(id: 3, prize: 300, isFixLevel: false, question: questions.getRandom(for: 3)),
            Level(id: 4, prize: 500, isFixLevel: true, question: questions.getRandom(for: 4)),
            Level(id: 5, prize: 1_000, isFixLevel: false, question: questions.getRandom(for: 5)),
            Level(id: 6, prize: 2_000, isFixLevel: false, question: questions.getRandom(for: 6)),
            Level(id: 7, prize: 4_000, isFixLevel: false, question: questions.getRandom(for: 7)),
            Level(id: 8, prize: 8_000, isFixLevel: false, question: questions.getRandom(for: 8)),
            Level(id: 9, prize: 16_000, isFixLevel: true, question: questions.getRandom(for: 9)),
            Level(id: 10, prize: 32_000, isFixLevel: false, question: questions.getRandom(for: 10)),
            Level(id: 11, prize: 64_000, isFixLevel: false, question: questions.getRandom(for: 11)),
            Level(id: 12, prize: 125_000, isFixLevel: false, question: questions.getRandom(for: 12)),
            Level(id: 13, prize: 500_000, isFixLevel: false, question: questions.getRandom(for: 13)),
            Level(id: 14, prize: 1_000_000, isFixLevel: false, question: questions.getRandom(for: 14))
        ]
    }
}
