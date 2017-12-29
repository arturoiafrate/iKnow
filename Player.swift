//
//  Player.swift
//  iKnow
//
//  Created by Arturo Iafrate on 22/09/17.
//  Copyright © 2017 Arturo Iafrate. All rights reserved.
//

import Foundation

class Player {
    var peerID: String = ""
    var nickname: String = ""
    var color: Int = 0
    var rank: Int = 0
    var favoriteCategory: String = ""
    //r=1, g=2, y=3, b=4
    var correctQuestionsAnswered = 0
    func getPlayerInfo() -> [Any] {
        return [peerID, nickname, color, rank, favoriteCategory]
    }
    
    func initializePlayer(nick: String, col: Int) {
        nickname = nick
        color = col
    }
    
    func initializePlayer(nick: String, col: Int, cat: String) {
        nickname = nick
        color = col
        favoriteCategory = cat
    }
    
    func initializePlayer(peer: String, nick: String, col: Int, cat: String) {
        peerID = peer
        nickname = nick
        color = col
        favoriteCategory = cat
    }
    
    func setCategory(cat: String) {
        favoriteCategory = cat
    }
    
    func addToRank(toAdd: Int) {
        rank += toAdd
    }
    
    func printPlayerInfo() {
        print("peerID:\(peerID) - nickname: \(nickname) - favorite cat:\(favoriteCategory) - rank: \(rank) - correct answers: \(correctQuestionsAnswered)")
    }
}
