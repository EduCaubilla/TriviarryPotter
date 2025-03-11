//
//  InstructionsView.swift
//  TriviarryPotter
//
//  Created by Edu Caubilla on 10/3/25.
//

import SwiftUI

struct InstructionsView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            InfoBackgroundImage()

            VStack {
                Image("appiconwithradius")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .padding(.top)

                ScrollView {
                    Text("How To Play")
                        .font(.largeTitle)
                        .padding()

                    VStack(alignment: .leading) {
                        Text("Welcome to Triviarry Potter! In this game you will be asked random questions from the Harry Potter books and you must guess the right answer or you will lose points! 😱")
                            .padding([.leading, .bottom, .trailing])

                        Text("Each quetion is worth 5 point but if you guess a wrong answer you lose 1 point")
                            .padding([.leading, .bottom, .trailing])

                        Text("If you are struggling with a question there is an option to reveal a hint or revela the book that answers the question. But beware! Using these also minuses 1 point each")
                            .padding([.leading, .bottom, .trailing])

                        Text("When selecting the correct answer, you will be awarded all the points left for that question and they will be added to tour total score.")
                            .padding([.leading, .bottom, .trailing])
                    }
                    .font(.system(size: 18))
                    Text("Good luck, muggle!")
                        .font(.title)
                }
                .foregroundStyle(.black)

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                }
                .doneButton()
            }
        }
    }
}

#Preview {
    InstructionsView()
}
