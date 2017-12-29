//
//  GameViewController.swift
//  iKnow
//
//  Created by Arturo Iafrate on 22/09/17.
//  Copyright © 2017 Arturo Iafrate. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class GameViewController: UIViewController {
    
    var playerViewController = AVPlayerViewController ()
    var videoPlayer = AVPlayer ()
    var seconds = 10
    var timer = Timer()
    var timerImage = UIImage(named: "10.png")
    var timerImageView = UIImageView(image: UIImage(named: "10.png")!)
    var correctAnswer = ""
    var audioPlayer : AVAudioPlayer?
    
    var choosedMovie = 0

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.connectionManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //INIZIO QUI
        //choosedMovie = appDelegate.game.pickQuestion() //Scegli film
        //correctAnswer = appDelegate.game.getCurrentCorrectAnswer()
        choosedMovie = GameManager.manager.pickQuestion()
        correctAnswer = GameManager.manager.getCurrentCorrectAnswer()
        print("Choosed movie: \(choosedMovie)")
        guard let path = Bundle.main.path(forResource: "\(choosedMovie)START", ofType:"mp4") else {
            debugPrint("video.mp4 not found")
            return
        }
        videoPlayer = AVPlayer(url: URL(fileURLWithPath: path))
        playerViewController.player = videoPlayer
        self.appDelegate.connectionManager.sendCorrectAnswer(answer: self.correctAnswer)
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlayingSTART(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem)
        self.playerViewController.showsPlaybackControls = false
        self.present(playerViewController , animated : true) {
            self.playerViewController.player?.play()
        }
    }

    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(GameViewController.decreaseTimer)), userInfo: nil, repeats: true)
    }
    
    func decreaseTimer(){
        DispatchQueue.main.async {
            self.seconds -= 1
            if self.seconds == 5 {
                UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
                    self.timerImageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: nil)
            }
            if self.seconds == 0 {
                self.audioPlayer?.stop()
                self.appDelegate.connectionManager.sendDisableRemoteSignal()
                self.playerViewController.contentOverlayView?.removeFromSuperview()
                guard let path = Bundle.main.path(forResource: "\(self.choosedMovie)END", ofType:"mp4") else {
                    debugPrint("video.mp4 not found")
                    return
                }
                self.videoPlayer = AVPlayer(url: URL(fileURLWithPath: path))
                self.playerViewController.player = self.videoPlayer
                self.playerViewController.showsPlaybackControls = false
                NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlayingEND(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
                self.playerViewController.player?.play()
            }
            else {
                self.timerImage = UIImage(named: "\(self.seconds).png")
                self.timerImageView.image = self.timerImage
            }
        }
    }
    
    func playerDidFinishPlayingEND(note: NSNotification) {
        DispatchQueue.main.async {
            NotificationCenter.default.removeObserver(self)
            //let completed = self.appDelegate.game.incrementTurn()
            let completed = GameManager.manager.incrementTurn()
            if !completed {
                let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "infoScreen") as! InfoScreen
                self.playerViewController.present(nextViewController, animated:true, completion:nil)
            }
            else {
                let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "rankView") as! RankViewController
                self.playerViewController.present(nextViewController, animated:true, completion:nil)
                GameManager.manager.incrementRound()
            }
        }
    }
    
    func playerDidFinishPlayingSTART(note: NSNotification) {
        //Attivo i remote connessi
        appDelegate.connectionManager.sendEnableRemoteSignal()
        
        //Prendo le dimensioni dello schermo
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        playSound()
        
        //Metto in foreground un'immagine nera semitrasparente
        //let image = UIImage(named: "black.jpg")
        let image = UIImage(named: "black.jpg")
        let imageView = UIImageView(image: image!)
        imageView.alpha = CGFloat(0.75)
        imageView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        
        //Immagine del timer
        timerImageView.frame = CGRect(x: 1700, y: 5, width: 170, height: 170)
        
        //Recupero domanda e risposte
        //var qs = appDelegate.game.getCurrentQuestion()
        var qs = GameManager.manager.getCurrentQuestion()
        let question = UILabel()
        question.text = qs["Question"]!
        print("\(question.text!)")
        question.font = UIFont(name: "KGInimitableOriginal", size: 75)
        question.lineBreakMode = NSLineBreakMode.byWordWrapping
        question.numberOfLines = 2
        if question.text!.characters.count < 40 {
            question.font = question.font.withSize(75)
        } else {
            question.font = question.font.withSize(60)
        }
        question.textColor = UIColor.white
        question.frame = CGRect(x: 20, y: 150, width: screenWidth - 40, height: 170)
        question.textAlignment = .center
        
        let redAnswer = UILabel()
        redAnswer.text = qs["1"]!
        redAnswer.font = UIFont(name: "KGInimitableOriginal", size: 45)
        redAnswer.lineBreakMode = NSLineBreakMode.byWordWrapping
        redAnswer.numberOfLines = 2
        redAnswer.font = redAnswer.font.withSize(45)
        redAnswer.textColor = UIColor.red
        redAnswer.frame = CGRect(x: 150, y: 350, width: 800, height: 300)
        redAnswer.textAlignment = .center
        
        let greenAnswer = UILabel()
        greenAnswer.text = qs["2"]!
        greenAnswer.font = UIFont(name: "KGInimitableOriginal", size: 45)
        greenAnswer.lineBreakMode = NSLineBreakMode.byWordWrapping
        greenAnswer.numberOfLines = 2
        greenAnswer.font = greenAnswer.font.withSize(45)
        greenAnswer.textColor = UIColor.green
        greenAnswer.frame = CGRect(x: 1000, y: 350, width: 800, height: 300)
        greenAnswer.textAlignment = .center
        
        let yellowAnswer = UILabel()
        yellowAnswer.text = qs["3"]!
        yellowAnswer.font = UIFont(name: "KGInimitableOriginal", size: 45)
        yellowAnswer.lineBreakMode = NSLineBreakMode.byWordWrapping
        yellowAnswer.numberOfLines = 2
        yellowAnswer.font = yellowAnswer.font.withSize(45)
        yellowAnswer.textColor = UIColor.yellow
        yellowAnswer.frame = CGRect(x: 150, y: 700, width: 800, height: 300)
        yellowAnswer.textAlignment = .center
        
        let blueAnswer = UILabel()
        blueAnswer.text = qs["4"]!
        blueAnswer.font = UIFont(name: "KGInimitableOriginal", size: 45)
        blueAnswer.lineBreakMode = NSLineBreakMode.byWordWrapping
        blueAnswer.numberOfLines = 2
        blueAnswer.font = blueAnswer.font.withSize(45)
        blueAnswer.textColor = UIColor.blue
        blueAnswer.frame = CGRect(x: 1000, y: 700, width: 800, height: 300)
        blueAnswer.textAlignment = .center

        
        playerViewController.contentOverlayView?.addSubview(imageView)
        playerViewController.contentOverlayView?.addSubview(question)
        playerViewController.contentOverlayView?.addSubview(timerImageView)
        playerViewController.contentOverlayView?.addSubview(redAnswer)
        playerViewController.contentOverlayView?.addSubview(greenAnswer)
        playerViewController.contentOverlayView?.addSubview(yellowAnswer)
        playerViewController.contentOverlayView?.addSubview(blueAnswer)
        runTimer()
    }
    
    //MARK:- PLAY SOUND
    func playSound() {
        let path = Bundle.main.path(forResource: "heart", ofType:"mp3")!
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


extension GameViewController: ConnectionManagerDelegate {
    func connectedDevicesChanged(manager : ConnectionManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            print("Connections: \(connectedDevices)")
        }
    }
    func stringReceved(manager: ConnectionManager, riceved: String) {
        OperationQueue.main.addOperation {
            print("riceved: \(riceved)")
            var name: String = ""
            var color: String = ""
            if let start = riceved.range(of: "-"),
                let end  = riceved.range(of: "-", range: start.upperBound..<riceved.endIndex) {
                name = riceved[start.upperBound..<end.lowerBound]
            }
            if let start = riceved.range(of: "+"),
                let end  = riceved.range(of: "+", range: start.upperBound..<riceved.endIndex) {
                color = riceved[start.upperBound..<end.lowerBound]
            }
            if color == self.correctAnswer {
                //self.appDelegate.game.addRankForPlayer(nickname: name, timeLeft: self.seconds)
                GameManager.manager.addRankForPlayer(nickname: name, timeLeft: self.seconds)
            }
            
        }
    }
}
