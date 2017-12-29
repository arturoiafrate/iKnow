//
//  ConnectionManager.swift
//  iKnow
//
//  Created by Arturo Iafrate on 22/09/17.
//  Copyright © 2017 Arturo Iafrate. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ConnectionManagerDelegate {
    
    func connectedDevicesChanged(manager : ConnectionManager, connectedDevices: [String])
    func stringReceved(manager: ConnectionManager, riceved: String)
}

class ConnectionManager: NSObject {
    
    private let myServiceType = "iknow-app"
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser //Hosting
    private let serviceBrowser : MCNearbyServiceBrowser //Ricerca
    var delegate : ConnectionManagerDelegate?
    public var isConnected: Bool = false
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: myServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: myServiceType)
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
        self.serviceAdvertiser.startAdvertisingPeer()
        self.isConnected = false
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func sendPlayerInfo(nick: String, color: Int, category: String) {
        //1 = playerInfo
        let peerID = session.myPeerID.displayName
        let stringToSend = "1{\(peerID)}-\(nick)-+\(color)+*\(category)*"
        send(toSend: stringToSend)
    }
    
    func sendStartGameSignal(){
        send2(toSend: "PLAY")
    }
    
    func sendEnableRemoteSignal(){
        send(toSend: "ENABLE")
    }
    
    func sendDisableRemoteSignal(){
        send(toSend: "DISABLE")
    }
    
    func sendNewGameSignal(){
        send(toSend: "NEWGAME")
    }
    
    func sendCorrectAnswer(answer: String){
        send(toSend: answer)
    }
    
    func sendAnswer(nick: String, color: String) {
        let stringToSend = "2-\(nick)-+\(color)+"
        send(toSend: stringToSend)
    }
    
    private func send(toSend: String) {
        NSLog("%@", "sending: \(toSend) to \(session.connectedPeers.count) peers")
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(toSend.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
    }
    private func send2(toSend: String) {
        NSLog("%@", "sending: \(toSend) to \(session.connectedPeers.count) peers")
        if session.connectedPeers.count > 0 {
            for i in 0...(session.connectedPeers.count - 1) {
                let playerIndex = GameManager.manager.getPlayerIndexFrom(peerName: session.connectedPeers[i].displayName)
                if playerIndex != -1 {
                    do {
                        try self.session.send(toSend.data(using: .utf8)!, toPeers: [session.connectedPeers[i]], with: .reliable)
                    }
                    catch let error {
                        NSLog("%@", "Error for sending: \(error)")
                    }
                }
            }
        }
    }
}

extension ConnectionManager : MCNearbyServiceAdvertiserDelegate { //Per accettare
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
}

extension ConnectionManager : MCNearbyServiceBrowserDelegate { //Per invitare
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
}

extension ConnectionManager : MCSessionDelegate { //Ricevuta
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state)")
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            self.isConnected = true
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let str = String(data: data, encoding: .utf8)!
        self.delegate?.stringReceved(manager: self, riceved: str)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
}
