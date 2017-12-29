//
//  InfoScreen.swift
//  iKnow
//
//  Created by Arturo Iafrate on 26/09/17.
//  Copyright © 2017 Arturo Iafrate. All rights reserved.
//

import UIKit

class InfoScreen: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var playerColorImage: UIImageView!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    var seconds = 3
    var timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        seconds = 2
        //let turn = appDelegate.game.getCurrentTurn()
        let turn = GameManager.manager.getCurrentTurn()
//        playerNameLabel.text = "\(appDelegate.game.players[turn].nickname)'s turn"
//        let userColor = appDelegate.game.players[turn].color
//        categoryLabel.text = appDelegate.game.players[turn].favoriteCategory
        playerNameLabel.text = "\(GameManager.manager.players[turn].nickname)'s turn"
        playerNameLabel.font = UIFont(name: "KGInimitableOriginal", size: 120)
        playerNameLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        playerNameLabel.numberOfLines = 2
        let userColor = GameManager.manager.players[turn].color
        categoryLabel.text = GameManager.manager.players[turn].favoriteCategory
        playerColorImage.image = UIImage(named: "color\(userColor)")
        runTimer()
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(InfoScreen.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func updateTimer() {
        seconds -= 1     //This will decrement(count down)the seconds.
        if seconds == 0 {
            self.performSegue(withIdentifier: "showVideoSegue", sender: nil)
        }
    }

}
