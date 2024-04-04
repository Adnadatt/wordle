//
//  ContentView.swift
//  Wordle
//
//  Created by Amanda Chen on 3/8/24.
//
import SwiftUI
import AVFAudio
struct Letter: Identifiable, Equatable, Hashable {
    var id = UUID()
    var name: Character
    var color: Color
    init(name: Character, color: Color) {
        id = UUID()
        self.name = name
        self.color = color
    }
    init(){
        id = UUID()
        name = Character(" ")
        color = .white
    }
}
struct ContentView: View {
    @State private var playing = true
    @State private var wordIndex = 0
    @State private var board: [[Letter]] = [[Letter(),Letter(),Letter(),Letter(),Letter()],[Letter(),Letter(),Letter(),Letter(),Letter()],[Letter(),Letter(),Letter(),Letter(),Letter()],[Letter(),Letter(),Letter(),Letter(),Letter()],[Letter(),Letter(),Letter(),Letter(),Letter()],[Letter(),Letter(),Letter(),Letter(),Letter()]]
    @State private var enteredWord = ""
    @State private var guess = 0
    @State private var correctGuess = false
    @State private var rightWrongText = ""
    @State private var wordsGuessedCorrectly = 0
    @State private var wordsGuessedIncorrectly = 0
    @State private var avgGuesses = 0.0
    
    @State private var audioPlayer: AVAudioPlayer!
    
    let words = ["APPLE", "BAKER", "CANDY", "DANCE", "EAGER", "FANCY", "GLOBE", "HAPPY", "JOLLY", "KITTY", "LEMON", "MANGO", "NOBLE", "OPERA", "PIANO", "QUACK", "ROAST", "SILLY", "TIGER", "UMBRA", "VOCAL", "WATER", "XENON", "YACHT", "ZEBRA", "ALARM", "BEACH", "CLOUD", "DREAM", "EAGLE", "FUDGE", "GLAZE", "HOUND", "IGLOO", "JUICE", "KOALA", "LASER", "MIRTH", "NOBLE", "OCEAN", "PEACE", "QUAIL", "ROBIN", "SCENT", "TOAST", "ULTRA", "VIRUS", "WALTZ", "XEROX", "YIELD", "ALBUM", "BRAVE", "CHARM", "DAISY", "FLORA", "GIANT", "HAZEL", "IVORY", "JUMBO", "KEBAB", "LATCH", "MELON", "NOVEL", "OCCUR", "PUPIL", "QUERY", "RUMBA", "SALSA", "TREAT", "USAGE", "VIGOR", "WIDEN", "XENON", "YUMMY", "ALLOY", "BLISS", "CRISP", "DWELL", "EMOTE", "FLUTE", "GLOOM", "HASTE", "JOUST", "KIOSK", "LUNAR", "MERRY", "NIFTY", "OASIS", "PEACH", "QUICK", "RADAR", "SAVOR", "TREND", "UNITY", "VALOR", "WATCH", "XENON", "YOUTH", "ZEBRA"]
    var body: some View {
        ZStack{
            VStack {
                Spacer()
                Text("WORDLE")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                ForEach(board, id: \.self){ word in
                    HStack{
                        ForEach(word){ letter in
                            ZStack{
                                Rectangle()
                                    .strokeBorder(.gray, lineWidth: 2)
                                    .background(letter.color)
                                Text(String(letter.name))
                                    .font(.title)
                                    .padding(.horizontal)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .frame(height: 65)
                }
                Divider()
                    .frame(height: 20)
                
                TextField("Enter A Word", text: $enteredWord)
                    .textInputAutocapitalization(.characters)
                    .keyboardType(.asciiCapable)
                    .autocorrectionDisabled(true)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .onChange(of: enteredWord) { _ in
                        if(!(enteredWord.isEmpty)){
                            if((enteredWord.last?.isLetter) == false){
                                enteredWord.removeLast()
                            }
                            if(enteredWord.count > 5){
                                enteredWord.removeLast()
                            }
                            if((enteredWord.last?.isUppercase) == false){
                                enteredWord.removeLast()
                            }
                        }
                        
                    }
                    .onSubmit {
                        guessWord(wordGuessed: enteredWord)
                        enteredWord = ""
                    }
                
                
                Spacer()
            }
            
            if(!playing){
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .shadow(radius: 20)
                    .frame(height: 500)
                    .opacity(0.975)
                        
                VStack{
                    Spacer()
                    
//                    Image("wordleLogoWord")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 100)
                    
                    Text(rightWrongText)
                        .font(.title)
                        .padding()
                        .multilineTextAlignment(.center)
                    
                    Text("You used \(guess) guess\(guess == 1 ? "" : "es")")
                        .font(.title)
                        .padding()
                    
                    Text("The Wordle Was: " + words[wordIndex])
                        .font(.title)
                        .padding()
                    
                    Text("STATISTICS")
                        .font(.title)
                    
                    HStack{
                        VStack{
                            Text(String(wordsGuessedCorrectly))
                                .font(.largeTitle)
                            Text("Correct Guesses")
                                .font(.system(size: 10))
                        }
                        
                        Spacer()
                        
                        VStack{
                            Text(String(wordsGuessedIncorrectly))
                                .font(.largeTitle)
                            
                            Text("Incorrect Guesses")
                                .font(.system(size: 10))
                        }
                        
                        Spacer()
                        
                        VStack{
                            
                            Text(String(avgGuesses))
                                .font(.largeTitle)
                            
                            Text("Average Guesses")
                                .font(.system(size: 10))
                        }
                    }
                    .padding()
                                 
                    Button("Play Again?"){
                        playing = true
                        wordIndex = Int.random(in: 0...words.count)
                        guess = 0
                        board = [[Letter(),Letter(),Letter(),Letter(),Letter()],[Letter(),Letter(),Letter(),Letter(),Letter()],[Letter(),Letter(),Letter(),Letter(),Letter()],[Letter(),Letter(),Letter(),Letter(),Letter()],[Letter(),Letter(),Letter(),Letter(),Letter()],[Letter(),Letter(),Letter(),Letter(),Letter()]]
                        enteredWord = ""
                    }
                    .buttonStyle(.bordered)
                    .tint(.mint)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .padding()
    }
    func guessWord(wordGuessed: String){
        if(guess != 6) {
            guard wordGuessed.count == 5 else {
                return
            }
            for i in Range(0...4){
                DispatchQueue.main.asyncAfter(deadline: .now() + (0.5*Double(i))){
                    if(Array(wordGuessed)[i] == Array(words[wordIndex])[i]){
                        board[guess][i].color = .green
                        playSound(soundName: "correct")
                    } else if(words[wordIndex].contains(Array(wordGuessed)[i])){
                        board[guess][i].color = .yellow
                        playSound(soundName: "yellow")
                    } else {
                        board[guess][i].color = .gray
                    }
                    board[guess][i].name = Array(wordGuessed)[i]
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0001){
                guess += 1
                if(wordGuessed == words[wordIndex]){
                    //Winning
                    playSound(soundName: "sound\(Int.random(in: 0...4))")
                    playing = false;
                    correctGuess = true
                    rightWrongText = "Congrats you guessed the Wordle! 🎉"
                    wordsGuessedCorrectly += 1
                    if avgGuesses == 0.0 {
                        avgGuesses = Double(guess)
                    } else {
                        avgGuesses = (avgGuesses + Double(guess))/2
                    }
                    
                } else if (guess == 6){
                    //Losing
                    playing = false;
                    rightWrongText = "You ran out of guesses, better luck next time 😢"
                    wordsGuessedIncorrectly += 1
                    if avgGuesses == 0.0 {
                        avgGuesses = Double(guess)
                    } else {
                        avgGuesses = (avgGuesses + Double(guess))/2
                    }
                }
                
            }
        }
    }
    func playSound(soundName: String){
        guard let soundFile = NSDataAsset(name: soundName) else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch{
            
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
