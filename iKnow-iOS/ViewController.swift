//
//  ViewController.swift
//  iKnow-iOS
//
//  Created by Arturo Iafrate on 22/09/17.
//  Copyright © 2017 Arturo Iafrate. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var playerNickname: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerNickname.delegate = self
        UIApplication.shared.isIdleTimerDisabled = true
        // Do any additional setup after loading the view, typically from a nib.
        //appDelegate.connectionManager.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            self.joinButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func SendInfo(_ sender: UIButton) {
        var nickname = playerNickname.text!
        let color = Int(arc4random_uniform(8))
        if playerNickname.text!.characters.count == 0 {
            nickname = "Player\(arc4random_uniform(99999))"
        }
        //OperationQueue.main.addOperation {
        DispatchQueue.main.async {
            self.joinButton.layer.removeAllAnimations()
            self.appDelegate.player.initializePlayer(nick: nickname, col: color)
            self.performSegue(withIdentifier: "categoryScreenSegue", sender: nil)
        }
    }

}

extension ViewController: ConnectionManagerDelegate {
    func connectedDevicesChanged(manager : ConnectionManager, connectedDevices: [String]) {
//        OperationQueue.main.addOperation {
//            print("Connections: \(connectedDevices)")
//        }
    }
    func stringReceved(manager: ConnectionManager, riceved: String) {
//        OperationQueue.main.addOperation {
//            print("riceved: \(riceved)")
//        }
    }
}
