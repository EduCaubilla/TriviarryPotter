//
//  GameViewModel.swift
//  TriviarryPotter
//
//  Created by Edu Caubilla on 11/3/25.
//

import Foundation
import SwiftUI

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameScore = 0
    @Published var questionScore = 5
    @Published var recentScores = [0,0,0]

    private var allQuestions: [Question] = []
    private var answeredQuestions: [Int] = []
    private let savePath = FileManager.documentsDirectory.appending(path: "SavedScores")

    var filteredQuestions: [Question] = []
    var currentQuestion = Constants.previewQuestion
    var answers : [String] = []

    var correctAnswer: String {
        currentQuestion.answers.first(where: { $0.value == true })!.key
    }

    init() {
        decodeQuestions()
    }

    func startGame() {
        gameScore = 0
        questionScore = 5
        answeredQuestions = []
    }

    func filterQuestions(to books: [Int]) {
        filteredQuestions = allQuestions.filter({ question in
            books.contains(question.book)
        })
    }

    func newQuestion() {
        if filteredQuestions.isEmpty { return }

        if answeredQuestions.count == filteredQuestions.count {
            answeredQuestions = []
        }

        var potentialQuestion = filteredQuestions.randomElement()!
        while answeredQuestions.contains(potentialQuestion.id) {
            potentialQuestion = filteredQuestions.randomElement()!
        }
        currentQuestion = potentialQuestion

        answers = []
        for answer in currentQuestion.answers.keys {
            answers.append(answer)
        }
        answers.shuffle()

        questionScore = 5
    }

    func correct() {
        answeredQuestions.append(currentQuestion.id)

        withAnimation {
            gameScore += questionScore
        }
    }

    func endGame() {
        recentScores[2] = recentScores[1]
        recentScores[1] = recentScores[0]
        recentScores[0] = gameScore

        saveScores()
    }

    private func saveScores() {
        do {
            let data = try JSONEncoder().encode(recentScores)
            try data.write(to: savePath)
        } catch  {
            print("Unable to save data")
        }
    }

    func loadScores() {
        do {
            let data = try Data(contentsOf: savePath)
            recentScores = try JSONDecoder().decode([Int].self, from: data)
        } catch {
            print("Unable to load scores")
            recentScores = [0,0,0]
        }
    }

    private func decodeQuestions () {
        if let url = Bundle.main.url(forResource: "trivia", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                allQuestions = try decoder.decode([Question].self, from: data)
                filteredQuestions = allQuestions
            } catch {
                print("Error decoding json data : \(error)")
            }
        }
    }

}
