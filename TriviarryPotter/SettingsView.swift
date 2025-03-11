//
//  SettingsView.swift
//  TriviarryPotter
//
//  Created by Edu Caubilla on 10/3/25.
//

import SwiftUI

struct SettingsView: View {

    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var store : Store

    var body: some View {
        ZStack {
            InfoBackgroundImage()

            VStack {
                Text("Which books would you like to see questions from?")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.top)

                ScrollView {
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(0..<7) { i in
                            if store.books[i] == .active || (store.books[i] == .locked && store.purchasedIDs.contains("hp\(i+1)")) {
                                ZStack(alignment: .bottomTrailing) {
                                    Image("hp\(i+1)")
                                        .resizable()
                                        .scaledToFit()
                                        .shadow(radius: 7)

                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.largeTitle)
                                        .imageScale(.large)
                                        .foregroundStyle(.green)
                                        .shadow(radius: 1)
                                        .padding(6)
                                }
                                .task {
                                    store.books[i] = .active
                                    store.saveBookStatuses()
                                }
                                .onTapGesture {
                                    store.books[i] = .inactive
                                    store.saveBookStatuses()
                                }
                            } else if store.books[i] == .inactive {
                                ZStack(alignment: .bottomTrailing) {
                                    Image("hp\(i+1)")
                                        .resizable()
                                        .scaledToFit()
                                        .shadow(radius: 7)
                                        .overlay(Rectangle().opacity(0.33))

                                    Image(systemName: "circle")
                                        .font(.largeTitle)
                                        .imageScale(.large)
                                        .foregroundStyle(.gray.opacity(0.5))
                                        .shadow(radius: 1)
                                        .padding(6)
                                }
                                .onTapGesture {
                                    store.books[i] = .active
                                    store.saveBookStatuses()
                                }
                            } else if store.books[i] == .locked {
                                ZStack {
                                    Image("hp\(i+1)")
                                        .resizable()
                                        .scaledToFit()
                                        .shadow(radius: 7)
                                        .overlay(Rectangle().opacity(0.75))

                                    Image(systemName: "lock.fill")
                                        .font(.largeTitle)
                                        .imageScale(.large)
                                        .shadow(color: .white.opacity(0.75), radius: 3)
                                }
                                .onTapGesture {
                                    let product = store.products[i-3]
                                    print("Product to purchase : \(product.displayName)")

                                    Task {
                                        await store.purchase(product)
                                    }
                                }
                            }
                        }
                        .padding([.leading, .bottom, .trailing], 18)
                    }
                }

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                }
                .doneButton()
            }
            .foregroundStyle(.black)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(Store())
}
