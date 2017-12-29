//
//  GameManager.swift
//  iKnow
//
//  Created by Arturo Iafrate on 23/09/17.
//  Copyright © 2017 Arturo Iafrate. All rights reserved.
//

import UIKit

class GameManager: NSObject {
    public var players: [Player] = []
    public var sortedPlayers : [Player] = []
    private var turn = 0
    private var alreadyChoosedQuestions: [Int] = []
    private var pickedQuestion: Int = 0
    private var round: Int = 0
    public static var manager = GameManager()
    private var tvSeriesPicked: Int = 0
    private var applesPicked: Int = 0
    private var filmsPicked: Int = 0
    private var animesPicked: Int = 0
    private var musicsPicked: Int = 0
    private var sportsPicked: Int = 0
    
    public func addPlayer(player: Player) {
        players.append(player)
        sortedPlayers.append(player)
        print("Players count = \(players.count)")
    }
    
    func sortPlayersForRanking() {
        sortedPlayers = players
        sortedPlayers.sort() { $0.rank > $1.rank }
    }
    
    
    public func removePlayer(peerID: String) {
        if let i = players.index(where: {$0.peerID == peerID}) {
            self.players.remove(at: i)
            self.sortedPlayers.remove(at: i)
        }
    }
    
    public func newGame() {
        players = []
        sortedPlayers = []
        turn = 0
        alreadyChoosedQuestions = []
        round = 0
        pickedQuestion = 0
        applesPicked = 0
        filmsPicked = 0
        animesPicked = 0
        musicsPicked = 0
        sportsPicked = 0
    }
    
    public func getPlayerIndexFrom(peerName: String) -> Int {
        if let i = players.index(where: {$0.peerID == peerName}) {
            print(players[i].peerID)
            return i
        } else {
            return -1
        }
    }
    
    public func incrementRound() {
        round += 1
    }
    
    public func getRoundValue() -> Int {
        return round
    }
    
    public func getPlayersNumber() -> Int {
        return players.count
    }
    
    public func addRankForPlayer(nickname: String, timeLeft: Int) {
        let playerIndex = getPlayerForNickname(nickname: nickname)
        if timeLeft >= 7 {
            players[playerIndex].addToRank(toAdd: 3)
        } else if timeLeft <= 6 && timeLeft >= 3 {
            players[playerIndex].addToRank(toAdd: 2)
        } else {
            players[playerIndex].addToRank(toAdd: 1)
        }
        players[playerIndex].correctQuestionsAnswered += 1
        sortPlayersForRanking()
    }
    
    private func getPlayerForNickname(nickname: String) -> Int {
        if let i = players.index(where: {$0.nickname == nickname}) {
            return i
        } else { return -1 }
    }
    
    public func turnTo0() {
        turn = 0
    }
    
    public func printPlayersInfo() {
        for player in players {
            player.printPlayerInfo()
        }
    }
    
    public func getCurrentCategoryCode() -> Int {
        print("Players= \(players.count) - turn= \(turn)")
        let currentCategory = players[turn].favoriteCategory
        print("-----CATEGORIA: \(currentCategory)")
        switch currentCategory {
        case "Film":
            return 1
        case "TV Series":
            return 2
        case "Sport":
            return 3
        case "Cartoon":
            return 4
        case "Music":
            return 5
        case "Apple":
            return 6
        default:
            return 1
        }
    }
    
    public func incrementTurn() -> Bool {
        turn += 1
        if turn >= players.count {
            turn = 0
            return true
        } else { return false }
    }
    
    public func getCurrentTurn() -> Int {
        return turn
    }
    
    public func pickQuestion() -> Int {
        let currentCategory = getCurrentCategoryCode()
        var choosedQuestion = 0
        var correctChoose = false
        while !correctChoose {
            //CAPIRE COME PRENDERE RANDOM DOMANDE
            switch currentCategory {
            case 1:
                if filmsPicked <= 5 {//aggiunto picked
                    choosedQuestion = 1 + Int(arc4random_uniform(4))
                    
                } else { choosedQuestion = 1 + Int(arc4random_uniform(26)) }
            case 2:
                if tvSeriesPicked < 5 {//aggiunto picked
                choosedQuestion = 6 + Int(arc4random_uniform(5))
                } else { choosedQuestion = 1 + Int(arc4random_uniform(26)) }
            case 3:
                if sportsPicked < 5 {//aggiunto picked
                choosedQuestion = 11 + Int(arc4random_uniform(5))
                } else { choosedQuestion = 1 + Int(arc4random_uniform(26)) }
            case 4:
                if animesPicked < 5 {//aggiunto picked
                    choosedQuestion = 16 + Int(arc4random_uniform(5))
                } else { choosedQuestion = 1 + Int(arc4random_uniform(26)) }
            case 5:
                if musicsPicked < 5 {//aggiunto picked
                choosedQuestion = 21 + Int(arc4random_uniform(5))
                } else { choosedQuestion = 1 + Int(arc4random_uniform(26)) }
            case 6:
                if applesPicked < 3 {//aggiunto picked
                    choosedQuestion = 26 + Int(arc4random_uniform(3))
                } else { choosedQuestion = 1 + Int(arc4random_uniform(26)) }
            default:
                choosedQuestion = 1 + Int(arc4random_uniform(26))
            }
            if !alreadyChoosedQuestions.contains(choosedQuestion) {
                alreadyChoosedQuestions.append(choosedQuestion)
                correctChoose = true
                if choosedQuestion <= 5 { //aggiunti controlli
                    filmsPicked += 1
                } else {
                    if choosedQuestion > 5 && choosedQuestion <= 10 {
                        tvSeriesPicked += 1
                    } else {
                        if choosedQuestion > 10 && choosedQuestion <= 15 {
                            sportsPicked += 1
                        } else {
                            if choosedQuestion > 15 && choosedQuestion <= 20 {
                                animesPicked += 1
                            } else {
                                if choosedQuestion > 20 && choosedQuestion <= 25 {
                                    musicsPicked += 1
                                } else {
                                    if choosedQuestion > 25 && choosedQuestion <= 28 {
                                        applesPicked += 1
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        pickedQuestion = choosedQuestion
        return choosedQuestion
    }
    
    public func getCurrentQuestion() -> [String: String] {
        print("picked: \(pickedQuestion)")
        return PlistManager.manager.getQuestionFor(key: "\(pickedQuestion)")
    }
    
    public func getCurrentCorrectAnswer() -> String {
        return PlistManager.manager.getCorrectAnswerFor(key: "\(pickedQuestion)")
    }
    
}
