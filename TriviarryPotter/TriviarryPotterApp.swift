//
//  TriviarryPotterApp.swift
//  TriviarryPotter
//
//  Created by Edu Caubilla on 10/3/25.
//

import SwiftUI

@main
struct TriviarryPotterApp: App {
    @StateObject private var store = Store()
    @StateObject private var game = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(game)
                .task {
                    await store.loadProducts()
                    game.loadScores()
                    store.loadBookStatuses()
                }
        }
    }
}
