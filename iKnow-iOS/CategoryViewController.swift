//
//  CategoryViewController.swift
//  iKnow-iOS
//
//  Created by Arturo Iafrate on 22/09/17.
//  Copyright © 2017 Arturo Iafrate. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var playerNickname: UILabel!
    @IBOutlet weak var playerColor: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    var timer = Timer()
    var passedSeconds = 0
    
    private let pickerElements: [UIImage] = [UIImage(named: "tvseries.png")!, UIImage(named: "film.png")!, UIImage(named: "anime.png")!,UIImage(named: "music.png")!,UIImage(named: "sport.png")!,UIImage(named: "apple.png")!]
    private var selectedItem: String = "TV Series"
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.connectionManager.delegate = self
        categoryPicker.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        playerNickname.text = appDelegate.player.nickname
        playerNickname.textColor = UIColor.white
        //playerNickname.font = UIFont.boldSystemFont(ofSize: playerNickname.font.pointSize)
        playerColor.image = UIImage(named:"color\(appDelegate.player.color)")
        playButton.isEnabled = false
        if appDelegate.connectionManager.isConnected {
            playButton.isEnabled = true
            UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
                self.playButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: nil)
        }
        passedSeconds = 0
        runTimer()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerElements.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            selectedItem = "TV Series"
        case 1:
            selectedItem = "Film"
        case 2:
            selectedItem = "Cartoon"
        case 3:
            selectedItem = "Music"
        case 4:
            selectedItem = "Sport"
        case 5:
            selectedItem = "Apple"
        default:
            selectedItem = "TV Series"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 120
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width - 30, height: 110))
        let myImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        var rowString = String()
        switch row {
        case 0:
            rowString = "TV Series"
            myImageView.image = UIImage(named: "tvseries.png")
        case 1:
            rowString = "Film"
            myImageView.image = UIImage(named: "film.png")
        case 2:
            rowString = "Cartoon"
            myImageView.image = UIImage(named: "anime.png")
        case 3:
            rowString = "Music"
            myImageView.image = UIImage(named: "music.png")
        case 4:
            rowString = "Sport"
            myImageView.image = UIImage(named: "sport.png")
        case 5:
            rowString = "Apple"
            myImageView.image = UIImage(named: "apple.png")
        default:
            rowString = "TV Series"
            myImageView.image = UIImage(named: "tvseries.png")
        }
        let myLabel = UILabel(frame: CGRect(x: 150, y: 30, width: pickerView.bounds.width - 90, height: 60))
        myLabel.text = rowString
        myLabel.font = UIFont(name:"KGInimitableOriginal" , size: 30)
        myLabel.textColor = UIColor.white
        //myLabel.font = UIFont.boldSystemFont(ofSize: myLabel.font.pointSize)
        myView.addSubview(myLabel)
        myView.addSubview(myImageView)
        return myView
    }

    @IBAction func playPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.playButton.layer.removeAllAnimations()
            self.appDelegate.player.setCategory(cat: self.selectedItem)
            self.appDelegate.connectionManager.sendPlayerInfo(nick: self.appDelegate.player.nickname, color: self.appDelegate.player.color, category: self.selectedItem)
            let alert = UIAlertController(title: "Please wait...", message: "The game will start shortly", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
        }
    }
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(CategoryViewController.decreaseTimer)), userInfo: nil, repeats: true)
    }
    
    func decreaseTimer() {
        passedSeconds += 1
        if passedSeconds%3 == 0 {
            if appDelegate.connectionManager.isConnected {
                playButton.isEnabled = true
                UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
                    self.playButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                }, completion: nil)
            }
        }
    }
    
}

extension CategoryViewController: ConnectionManagerDelegate {
    func connectedDevicesChanged(manager : ConnectionManager, connectedDevices: [String]) {
        if self.appDelegate.connectionManager.isConnected && !playButton.isEnabled {
            playButton.isEnabled = true
            UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
                self.playButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            }, completion: nil)
        }
    }
    func stringReceved(manager: ConnectionManager, riceved: String) {
                OperationQueue.main.addOperation {
                    if riceved == "PLAY" {
                        self.performSegue(withIdentifier: "gameScreenSegue", sender: nil)
                    }
                }
    }
}
