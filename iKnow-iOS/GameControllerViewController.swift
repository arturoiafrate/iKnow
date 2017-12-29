//
//  GameControllerViewController.swift
//  iKnow-iOS
//
//  Created by Arturo Iafrate on 23/09/17.
//  Copyright © 2017 Arturo Iafrate. All rights reserved.
//

import UIKit

class GameControllerViewController: UIViewController {
    @IBOutlet weak var helpBarOutlet: UIButton!
    @IBOutlet weak var playerColor: UIImageView!
    @IBOutlet weak var playerName: UILabel!
    
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    
    public var helpBar = 3
    public var colorSent = ""
    public var correctAnswer = ""
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.connectionManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        playerName.text = appDelegate.player.nickname
        playerName.textColor = UIColor.white
        playerColor.image = UIImage(named:"color\(appDelegate.player.color)")
        disableRemote()
    }
    

    @IBAction func helpRequest(_ sender: UIButton) {
        //aiuto
        helpBar = 0
        helpBarOutlet.isEnabled = false
        helpBarOutlet.setImage(UIImage(named: "00.png"), for: .normal)
        var x: Int = 0
        var y: Int = 0
        while x != 2 {
            let random = 1 + Int(arc4random_uniform(4))
            if "\(random)" != correctAnswer && random != y {
                 x += 1
                switch random {
                case 1:
                    redButton.isEnabled = false
                    y = 1
                case 2:
                    greenButton.isEnabled = false
                    y = 2
                case 3:
                    yellowButton.isEnabled = false
                    y = 3
                case 4:
                    blueButton.isEnabled = false
                    y = 4
                default:
                    blueButton.isEnabled = false
                    y = 4
                }
            }
        }
        //cambia immagine
    }
    @IBAction func redAnswer(_ sender: UIButton) {
        appDelegate.connectionManager.sendAnswer(nick: appDelegate.player.nickname, color: "1")
        redButton.imageView?.image = UIImage(named: "b22.png")
        disableRemote()
        colorSent = "1"
        checkIfCorrect()
    }
    @IBAction func greenAnswer(_ sender: UIButton) {
        appDelegate.connectionManager.sendAnswer(nick: appDelegate.player.nickname, color: "2")
        greenButton.imageView?.image = UIImage(named: "b11.png")
        disableRemote()
        colorSent = "2"
        checkIfCorrect()
    }
    @IBAction func yellowAnswer(_ sender: UIButton) {
        appDelegate.connectionManager.sendAnswer(nick: appDelegate.player.nickname, color: "3")
        yellowButton.imageView?.image = UIImage(named: "b44.png")
        disableRemote()
        colorSent = "3"
        checkIfCorrect()
    }
    @IBAction func blueAnswer(_ sender: UIButton) {
        appDelegate.connectionManager.sendAnswer(nick: appDelegate.player.nickname, color: "4")
        blueButton.imageView?.image = UIImage(named: "b33.png")
        disableRemote()
        colorSent = "4"
        checkIfCorrect()
    }
    
    func disableRemote() {
        helpBarOutlet.isEnabled = false
        redButton.isEnabled = false
        greenButton.isEnabled = false
        yellowButton.isEnabled = false
        blueButton.isEnabled = false
        redButton.imageView?.image = UIImage(named: "b22.png")
        greenButton.imageView?.image = UIImage(named: "b11.png")
        blueButton.imageView?.image = UIImage(named: "b33.png")
        yellowButton.imageView?.image = UIImage(named: "b44.png")
    }
    
    func enableRemote() {
        if helpBar >= 3 {
            helpBarOutlet.isEnabled = true
        }
        redButton.isEnabled = true
        greenButton.isEnabled = true
        yellowButton.isEnabled = true
        blueButton.isEnabled = true
        redButton.imageView?.image = UIImage(named: "b2.png")
        greenButton.imageView?.image = UIImage(named: "b1.png")
        blueButton.imageView?.image = UIImage(named: "b3.png")
        yellowButton.imageView?.image = UIImage(named: "b4.png")
    }
    
    func checkIfCorrect() {
        if colorSent == correctAnswer {
            print("Ho risposto correttamente")
            if helpBar < 3 {
                helpBar += 1
                helpBarOutlet.setImage(UIImage(named: "0\(helpBar).png"), for: .normal)
            }
            if helpBar == 3 {
                helpBarOutlet.isEnabled = true
            }
        } else { print("Risposta errata") }
    }
}

extension GameControllerViewController: ConnectionManagerDelegate {
    func connectedDevicesChanged(manager : ConnectionManager, connectedDevices: [String]) {
        //        OperationQueue.main.addOperation {
        //            print("Connections: \(connectedDevices)")
        //        }
    }
    func stringReceved(manager: ConnectionManager, riceved: String) {
        OperationQueue.main.addOperation {
            if riceved == "ENABLE" {
                self.enableRemote()
            }
            else if riceved == "DISABLE" {
                self.disableRemote()
            }
            else {
                if riceved == "NEXT"{
                  //prossima
                } else {
                    if riceved == "NEWGAME" {
                        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "categoryView") as! CategoryViewController
                        self.present(nextViewController, animated:true, completion:nil)
                    }
                    else {
                        self.correctAnswer = riceved
                    }
                }

            }
        }
    }
}
