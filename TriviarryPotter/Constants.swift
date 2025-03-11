//
//  Constants.swift
//  TriviarryPotter
//
//  Created by Edu Caubilla on 10/3/25.
//

import Foundation
import SwiftUI

enum Constants {
    static let hpFont = "PartyLetPlain"
    
    static let flipSound = "page-flip"
    static let wrongSound = "negative-beeps"
    static let correctSound = "magic-wand"

    static let previewQuestion = try! JSONDecoder().decode([Question].self, from: Data(contentsOf: Bundle.main.url(forResource: "trivia", withExtension: "json")!))[0]
}

struct InfoBackgroundImage: View {
    var body: some View {
        Image("parchment")
            .resizable()
            .ignoresSafeArea()
            .scaleEffect(1.2)
    }
}

extension Button {
    func doneButton() -> some View {
        self
            .font(.title)
            .padding()
            .buttonStyle(.borderedProminent)
            .tint(.brown)
            .foregroundStyle(.white)
    }
}

extension View {
    func setGeoSize(geo : GeometryProxy, width: Double = 1, height: Double = 1) -> some View {
        self
            .frame(width: geo.size.width * width, height: geo.size.height * height)
    }
}

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
