//
//  RankViewController.swift
//  iKnow
//
//  Created by Arturo Iafrate on 26/09/17.
//  Copyright © 2017 Arturo Iafrate. All rights reserved.
//

import UIKit

class RankViewController: UIViewController{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var seconds: Int = 5
    var timer = Timer()
    
    @IBOutlet weak var rankingTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rankingTable.dataSource = self
        rankingTable.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runTimer()
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(RankViewController.decreaseTimer)), userInfo: nil, repeats: true)
    }
    
    func decreaseTimer(){
        DispatchQueue.main.async {
            self.seconds -= 1
            if self.seconds == 0 {
                //let currentRound = self.appDelegate.game.getRoundValue()
                let currentRound = GameManager.manager.getRoundValue()
                GameManager.manager.turnTo0()
                print("current round: \(currentRound)")
                if currentRound >= 3 {
                    GameManager.manager.newGame()
                    let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "firstView") as! FirstViewController
                    self.appDelegate.connectionManager.sendNewGameSignal()
                    self.present(nextViewController, animated:true, completion:nil)
                }
                else {
                    let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "infoScreen") as! InfoScreen
                    self.present(nextViewController, animated:true, completion:nil)
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RankViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let player = GameManager.manager.sortedPlayers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerRankingCell", for: indexPath) as! RankingCellPrototypeTableViewCell
        cell.playerName.text = player.nickname
        cell.playerScore.text = "\(player.rank)"
        cell.playerColor.image = UIImage(named: "color\(player.color)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GameManager.manager.players.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0;//Choose your custom row height
    }
}
