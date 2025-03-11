//
//  GameplayView.swift
//  TriviarryPotter
//
//  Created by Edu Caubilla on 10/3/25.
//

import SwiftUI
import AVKit

struct GameplayView: View {

    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var game : GameViewModel

    @Namespace private var namespace

    @State private var musicPlayer: AVAudioPlayer!
    @State private var sfxPlayer: AVAudioPlayer!

    @State private var animateViewsIn = false

    @State private var revealHint = false
    @State private var revealBook = false

    @State private var tappedCorrectAnswer = false
    @State private var wrongAnwersTapped : [Int] = []

    @State private var movePointsToScore = false

    @State private var objectWiggle = false
    @State private var scaleNextButton = false


    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("hogwarts")
                    .resizable()
                    .setGeoSize(geo: geo, width: 3, height: 1.05)
                    .overlay(Rectangle().foregroundStyle(.black.opacity(0.8)))

                VStack {
                    //MARK: - Controls
                    HStack {
                        Button("End Game") {
                            //End game
                            game.endGame()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red.opacity(0.5))

                        Spacer()

                        Text("Score: \(game.gameScore)")
                    }
                    .padding()
                    .padding(.vertical, 40)

                    //MARK: - Questions
                    VStack {
                        if animateViewsIn {
                            Text(game.currentQuestion.question)
                                .font(.custom(Constants.hpFont, size: 50))
                                .multilineTextAlignment(.center)
                                .padding()
                                .transition(.scale)
                                .opacity(tappedCorrectAnswer ? 0.1 : 1)
                        }
                    }
                    .animation(.easeInOut(duration: animateViewsIn ? 1.5 : 0), value: animateViewsIn )

                    Spacer()

                    //MARK: - Hints
                    HStack {
                        VStack {
                            if animateViewsIn {
                                Image(systemName: "questionmark.app.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                                    .foregroundStyle(.teal)
                                    .rotationEffect(.degrees(objectWiggle ? -8 : -12))
                                    .padding()
                                    .padding(.leading, 20)
                                    .transition(.offset(x: -geo.size.width/2))
                                    .onAppear{
                                        withAnimation(
                                            .easeInOut(duration: 0.1)
                                            .repeatCount(9)
                                            .delay(5)
                                            .repeatForever()) {
                                            objectWiggle = true
                                        }
                                    }
                                    .onTapGesture {
                                        withAnimation(.easeOut(duration: 1)) {
                                            revealHint = true
                                        }

                                        playFxSound(sound: Constants.flipSound)
                                        game.questionScore -= 1
                                    }
                                    .rotation3DEffect(.degrees(revealHint ? 1440 : 0), axis: (x: 0, y: 1, z: 0))
                                    .scaleEffect(revealHint ? 5 : 1)
                                    .opacity(revealHint ? 0 : 1)
                                    .offset(x: revealHint ? geo.size.width/2 : 0)
                                    .overlay(
                                        Text(game.currentQuestion.hint)
                                            .padding(.leading, 33)
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.center)
                                            .opacity(revealHint ? 1 : 0)
                                            .scaleEffect(revealHint ? 1.33 : 1)
                                    )
                                    .opacity(tappedCorrectAnswer ? 0.1 : 1)
                                    .disabled(tappedCorrectAnswer)
                            }
                        }
                        .animation(.easeOut(duration: animateViewsIn ? 2 : 0).delay(2), value: animateViewsIn)

                        Spacer()

                        VStack {
                            if animateViewsIn {
                                Image(systemName: "book.closed")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50)
                                    .foregroundStyle(.black)
                                    .frame(width: 100, height: 100)
                                    .background(.teal)
                                    .clipShape(.rect(cornerRadius: 15))
                                    .rotationEffect(.degrees(objectWiggle ? 8 : 12))
                                    .padding()
                                    .padding(.trailing, 20)
                                    .transition(.offset(x: geo.size.width/2))
                                    .onAppear{
                                        withAnimation(
                                            .easeInOut(duration: 0.1)
                                            .repeatCount(9)
                                            .delay(5)
                                            .repeatForever()) {
                                                objectWiggle = true
                                            }
                                    }
                                    .onTapGesture {
                                        withAnimation(.easeOut(duration: 1)) {
                                            revealBook = true
                                        }

                                        playFxSound(sound: Constants.flipSound)
                                        game.questionScore -= 1
                                    }
                                    .rotation3DEffect(.degrees(revealBook ? 1440 : 0), axis: (x: 0, y: 1, z: 0))
                                    .scaleEffect(revealBook ? 5 : 1)
                                    .opacity(revealBook ? 0 : 1)
                                    .offset(x: revealBook ? -geo.size.width/2 : 0)
                                    .overlay(
                                        Image("hp\(game.currentQuestion.book)")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(.trailing, 33)
                                            .padding(.bottom)
                                            .opacity(revealBook ? 1 : 0)
                                            .scaleEffect(revealBook ? 1.33 : 1)
                                    )
                                    .opacity(tappedCorrectAnswer ? 0.1 : 1)
                                    .disabled(tappedCorrectAnswer)
                            }
                        }
                        .animation(.easeOut(duration: animateViewsIn ? 1.5 : 0).delay(animateViewsIn ? 2 : 0), value: animateViewsIn)
                    }
                    .padding(.bottom, 20)

                    //MARK: - Answers
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(Array(game.answers.enumerated()), id:\.offset) { i, answer in
                            //Correct answer
                            if game.currentQuestion.answers[answer] == true {
                                VStack {
                                    if animateViewsIn {
                                        if tappedCorrectAnswer == false {
                                            Text(answer)
                                                .minimumScaleFactor(0.5)
                                                .multilineTextAlignment(.center)
                                                .padding(10)
                                                .frame(width: geo.size.width/2.15 , height: 80)
                                                .background(.green.opacity(0.50))
                                                .clipShape(.rect(cornerRadius: 25))
                                                .transition(
                                                    .asymmetric(insertion: .scale, removal: .scale(scale: 5).combined(with: .opacity.animation(.easeOut(duration: 0.5))))
                                                )
                                                .matchedGeometryEffect(id: "answer", in: namespace)
                                                .onTapGesture {
                                                    withAnimation(.easeOut(duration: 1)) {
                                                        tappedCorrectAnswer = true
                                                    }

                                                    playFxSound(sound: Constants.correctSound)

                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                                        game.correct()
                                                    }
                                                }
                                        }
                                    }
                                }
                                .animation(.easeOut(duration: animateViewsIn ? 1 : 0).delay(animateViewsIn ? 1.5 : 0), value: animateViewsIn)
                            //Incorrect answers
                            } else {
                                VStack {
                                    if animateViewsIn {
                                        Text(answer)
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.center)
                                            .padding(10)
                                            .setGeoSize(geo: geo, width: 0.45, height: 0.11)
                                            .background(wrongAnwersTapped.contains(i) ? .red.opacity(0.5) : .green.opacity(0.50))
                                            .clipShape(.rect(cornerRadius: 25))
                                            .transition(.scale)
                                            .onTapGesture {
                                                withAnimation(.easeOut(duration: 1)){
                                                    wrongAnwersTapped.append(i)
                                                }

                                                playFxSound(sound: Constants.wrongSound)
                                                giveWrongFeedback()
                                                game.questionScore -= 1
                                            }
                                            .scaleEffect(wrongAnwersTapped.contains(i) ? 0.8 : 1)
                                            .disabled(tappedCorrectAnswer || wrongAnwersTapped.contains(i))
                                            .opacity(tappedCorrectAnswer ? 0.1 : 1)
                                    }
                                }
                                .animation(.easeOut(duration: animateViewsIn ? 1 : 0).delay(animateViewsIn ? 1.5 : 0), value: animateViewsIn)
                            }
                        }
                    }

                    Spacer()
                }
                .setGeoSize(geo: geo)
                .foregroundStyle(.white)

                //MARK: - Celebration
                VStack {
                    Spacer()

                    VStack {
                        if tappedCorrectAnswer {
                            Text("\(game.questionScore)")
                                .font(.system(size: 75))
                                .padding(.top ,100)
                                .transition(.offset(y: -geo.size.height/4))
                                .offset(x: movePointsToScore ? geo.size.width/2.3 : 0, y: movePointsToScore ? -geo.size.height/8 : 0)
                                .opacity(movePointsToScore ? 0 : 1)
                                .onAppear{
                                    withAnimation (.easeInOut(duration:1).delay(3)) {
                                        movePointsToScore = true
                                    }
                                }                        }
                    }
                    .animation(.easeInOut(duration: 1).delay(2), value: tappedCorrectAnswer)

                    Spacer()

                    VStack {
                        if tappedCorrectAnswer {
                            Text("Brilliant!")
                                .font(.custom(Constants.hpFont, size: 100))
                                .padding(.top)
                                .transition(.scale.combined(with: .offset(y: -geo.size.height/2)))
                        }
                    }
                    .animation(.easeInOut(duration: animateViewsIn ? 1 : 0).delay(animateViewsIn ? 1 : 0), value: tappedCorrectAnswer)

                    Spacer()

                    if tappedCorrectAnswer {
                        Text(game.correctAnswer)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .padding(10)
                            .setGeoSize(geo: geo, width: 0.45, height: 0.1)
                            .background(.green.opacity(0.5))
                            .clipShape(.rect(cornerRadius: 25))
                            .scaleEffect(2)
                            .matchedGeometryEffect(id: "answer", in: namespace)
                    }

                    Group {
                        Spacer()
                        Spacer()
                    }

                    VStack {
                        if tappedCorrectAnswer {
                            Button("Next Level > ") {
                                // TODO: Reset level for next question
                                animateViewsIn = false
                                tappedCorrectAnswer = false
                                revealBook = false
                                revealHint = false
                                movePointsToScore = false
                                wrongAnwersTapped = []
                                game.newQuestion()

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    animateViewsIn = true
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue.opacity(0.5))
                            .font(.title)
                            .transition(.offset(y: geo.size.height/3))
                            .scaleEffect(scaleNextButton ? 1.1 : 1)
                            .onAppear {
                                withAnimation(
                                    .easeInOut(duration: 1.2).repeatForever()) {
                                    scaleNextButton.toggle()
                                }
                            }
                        }
                    }
                    .animation(.easeInOut(duration: animateViewsIn ? 2.7 : 0).delay(animateViewsIn ? 2.7 : 0), value: tappedCorrectAnswer)

                    Group {
                        Spacer()
                        Spacer()
                    }
                }
                .foregroundStyle(.white)
            }
            .setGeoSize(geo: geo)
        }
        .ignoresSafeArea()
        .onAppear {
            animateViewsIn = true

//            playMusic()
        }
    }

    private func playMusic() {
        let songs = ["let-the-mistery-unfold", "spellcraft" , "hiding-place-in-the-forest", "deep-in-the-dell"]

        let i = Int.random(in: 0...3)

        let sound = Bundle.main.path(forResource: songs[i], ofType: "mp3")
        print("Audio path : \(sound!)")
        musicPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        musicPlayer.volume = 0.1
        musicPlayer.numberOfLoops = -1
        musicPlayer.play()
    }

    private func playFxSound(sound: String) {
        let sound =  Bundle.main.path(forResource: sound, ofType: "mp3")
        sfxPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        sfxPlayer.volume = 0.5
        sfxPlayer.play()
    }

    private func giveWrongFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

#Preview {
    GameplayView()
        .environmentObject(GameViewModel())
}
