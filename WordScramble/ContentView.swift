//
//  ContentView.swift
//  WordScramble
//
//  Created by Travis Brigman on 2/2/21.
//  Copyright © 2021 Travis Brigman. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter you word", text: $newWord, onCommit: addNewWord)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }
        .navigationBarTitle(rootWord)
        .navigationBarItems(leading: Button(action: startNewGame) {
            Text("New Game")
        })
        .onAppear(perform: startNewGame)
            .alert(isPresented: $showingError){
                .init(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        
    }
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "word used already", message: "be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "word not recognized", message: "dont use made up words!")
            return
        }

        guard isReal(word: answer) else {
                wordError(title: "not possible", message: "not a real word")
                return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startNewGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try?
                String(contentsOf: startWordsURL) {
                    let allWords = startWords.components(separatedBy: "\n")
                    rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("couldnt load start.txt from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        if rootWord == word || word.count < 3 {
            return false
        }
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


