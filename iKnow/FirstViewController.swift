//
//  FirstViewController.swift
//  iKnow
//
//  Created by Arturo Iafrate on 22/09/17.
//  Copyright © 2017 Arturo Iafrate. All rights reserved.
//

import UIKit
import AVFoundation

class FirstViewController: UIViewController {
    
    @IBOutlet weak var waitImage: UIImageView!
    @IBOutlet weak var timerImage: UIImageView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var seconds = 10
    var timer = Timer()
    private let correctAnswer = "CorrectAnswer"
    private let questions = "Questions"
    var waitNumber = 1
    var ricevedCounter = 0
    var audioPlayer : AVAudioPlayer?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        appDelegate.connectionManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        GameManager.manager.newGame()
        ricevedCounter = 0
        runChangeWait()
        playSound()
    }
    
    func runChangeWait() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(FirstViewController.updateWaitImage)), userInfo: nil, repeats: true)
    }
    
    func updateWaitImage() {
        waitImage.image = UIImage(named: "wait\(waitNumber)")
        waitNumber += 1
        if waitNumber == 4 { waitNumber = 1 }
    }
    
    func runTimer() {
        timerImage.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(FirstViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    func updateTimer() {
        seconds -= 1     //This will decrement(count down)the seconds.
        if seconds == 5 {
            UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
                self.timerImage.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: nil)
        }
        if seconds == -1 {
            //Inizia il gioco
            self.audioPlayer?.stop()
            self.appDelegate.connectionManager.sendStartGameSignal()
            self.performSegue(withIdentifier: "playGameSegue", sender: nil)
        } else { timerImage.image = UIImage(named: "\(seconds)") }
    }
    
    //MARK:- PLAY SOUND
    func playSound() {
        let path = Bundle.main.path(forResource: "waitingMusic", ofType:"mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer = sound
            sound.numberOfLoops = 0
            sound.prepareToPlay()
            sound.play()
        } catch {
            print("error loading file")
            // couldn't load file :(
        }
    }
}

extension FirstViewController: ConnectionManagerDelegate {
    func connectedDevicesChanged(manager : ConnectionManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            print("Connections: \(connectedDevices)")
        }
    }
    func stringReceved(manager: ConnectionManager, riceved: String) {
        OperationQueue.main.addOperation {
            print("riceved: \(riceved)")
            self.ricevedCounter += 1
            var name: String = ""
            var color: Int = 0
            var category: String = ""
            var peerID: String = ""
            if let start = riceved.range(of: "{"),
                let end  = riceved.range(of: "}", range: start.upperBound..<riceved.endIndex) {
                peerID = riceved[start.upperBound..<end.lowerBound]
            }
            if let start = riceved.range(of: "-"),
                let end  = riceved.range(of: "-", range: start.upperBound..<riceved.endIndex) {
                name = riceved[start.upperBound..<end.lowerBound]
            }
            if let start = riceved.range(of: "+"),
                let end  = riceved.range(of: "+", range: start.upperBound..<riceved.endIndex) {
                let stringColor = riceved[start.upperBound..<end.lowerBound]
                color = Int(stringColor)!
            }
            if let start = riceved.range(of: "*"),
                let end  = riceved.range(of: "*", range: start.upperBound..<riceved.endIndex) {
                category = riceved[start.upperBound..<end.lowerBound]
            }
            let x: Player = Player()
            x.initializePlayer(peer: peerID,nick: name, col: color, cat: category)
            GameManager.manager.addPlayer(player: x)
            if self.ricevedCounter == 1 {
                self.runTimer()
            }
            print("counter: \(GameManager.manager.getPlayersNumber())")
        }
    }
}
