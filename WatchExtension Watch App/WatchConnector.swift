//
//  WatchConnector.swift
//  WatchExtension Watch App
//
//  Created by John on 20/12/23.
//

import Foundation
 import WatchConnectivity

////MARK: WATCH CONNECTOR OT GET THE VALUE FROM IOS AND HANDEL THE DATA
//class WatchConnector :  NSObject, ObservableObject, WCSessionDelegate {
//   
//    
//    var session : WCSession
//    @Published var receivedmessage = ""
//    
//    init(session: WCSession = .default) {
//        self.session = session
//        super.init()
//        self.session.delegate = self
//        session.activate()
//      
//    }
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        
//    }
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        DispatchQueue.main.async {
//            self.receivedmessage = message["message"] as? String ?? ""
//            print("Receivermessage  ==>" + self.receivedmessage)
//            UserDefaults.standard.setValue(self.receivedmessage, forKey: "message")
//        }
//    }
//}


//MARK: SEND THE DATA FROM WATCH
class WatchConnectivityDelegate: NSObject, ObservableObject, WCSessionDelegate {

    
    var session : WCSession
 
     init(session :WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
       
    }


    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

    }
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {

    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
       

    }
}
