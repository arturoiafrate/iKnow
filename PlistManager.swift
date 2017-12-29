//
//  PlistManager.swift
//  iKnow
//
//  Created by Arturo Iafrate on 26/09/17.
//  Copyright © 2017 Arturo Iafrate. All rights reserved.
//

import Foundation

class PlistManager{
    public var questions: [String: [String: String]] = [String:[String: String]]()
    public var answer: [String: String] = [String: String]()
    static var manager = PlistManager()
    
    init() {
        loadQuestions()
        loadAnswer()
    }
    
    private func loadQuestions(){
        if let path = Bundle.main.path(forResource: "Questions", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: [String: String]] {
            self.questions = dict
        }
    }
    
    private func loadAnswer(){
        if let path = Bundle.main.path(forResource: "CorrectAnswer", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            self.answer = dict
        }
    }
    
    public func getQuestionFor(key: String) -> [String: String]{
        return questions[key]!
    }
    
    
    public func getCorrectAnswerFor(key: String) -> String {
        return answer[key]!
    }
}
