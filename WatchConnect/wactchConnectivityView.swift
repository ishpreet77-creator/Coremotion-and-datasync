//
//  wactchConnectivityView.swift
//  WatchConnect
//
//  Created by John on 20/12/23.
//

import SwiftUI
import WatchConnectivity
import Combine

struct wactchConnectivityView: View {
    @State private var receivedMessage: String = "No message"
    @ObservedObject var watchConnector = WatchConnector()
    @State var message = ""
    @State var cancellables: Set<AnyCancellable> = []
    //MARK: CHECK THE WATCH IS CONNECTED OR NOT
    @State private var watchActivated = false
    func activatewatch(){
        if self.watchConnector.session.isReachable{
             print("watch is connected")
            self.watchActivated = true
      
        }else{
            print("watch is NOT connected")
           self.watchActivated = false
        }
    }
    //MARK:  GET MESSAGE WITH FUNCTION REFRESH
    func getMEssageFromIphone(){
        if let storagerecived = UserDefaults.standard.string(forKey: "message"){
            self.message = storagerecived.description
        }else{
            self.message = ""
            print("could not get message form watch memory")
        }
    }
    //MARK: VIEW TO MANAGE THE WACTH SCREEN
    var body: some View {
           VStack {
           
               if watchActivated == true {
                   Text("watch  is connected")
               }else{
                   Text("watch is not connected")
                       
               }
               if (self.message == ""){
                   Text("No Message recived form iphone")
                       
               }
               else{
                   Text("DATA:" + message)
               }
            
//MARK: CALL THE GETMESSAGE FUNCTION FORM IPHONE FOR IF HANDEL WITH BUTTON
//               Button {
//                   getMEssageFromIphone()
//               } label: {
//                   Text("Refresh")
//               }

                  
            //MARK: HANDEL THE DATA WITH IF LISNNG THE DATA FOR IWATCH SEND
               
           }.onAppear {
               // Start listening for changes
               watchConnector.$receivedmessage
                   .receive(on: RunLoop.main)
                   .sink { newMessage in
                       self.message = newMessage
                   }
                   .store(in: &cancellables)
           }
           .onAppear(perform: {
               activatewatch()
           })
       }
}



//MARK: SEND THE DATA TO WATCH
//struct wactchConnectivityView: View {
//    @State private var watchActivated = false
//    @State private var watchMessage = ""
//    var watchconnection = WatchConnectivityDelegate()
//MARK: CHECK WATCH CONNECTION AND CONNECT TO THE WATCH 
//    func activatewatch (){
//        if self.watchconnection.session.isReachable{
//             print("watch is connected")
//            self.watchActivated = true
//      
//        }else{
//            print("watch is NOT connected")
//           self.watchActivated = false
//        }
//    }
//MARK: SEND THE DATA TO WATCH FROM IPHONE
//    func sendMessagetoWatch(){
//        if self.watchconnection.session.isReachable{
//             print("watch is connected")
//            self.watchActivated = true
//            self.watchconnection.session.sendMessage(["message": String(self.watchMessage)], replyHandler: nil, errorHandler: { error in
//                print("Watch ERROR SENDING MESSGA E - " + error.localizedDescription)
//            })
//           
//        }else{
//            print("watch is NOT connected")
//           self.watchActivated = false
//        }
//    }
//    var body: some View {
//          VStack {
//
//
//              if watchActivated == true {
//                  Text("watch  is connected")
//              }else{
//                  Text("watch is not connected")
//                      
//              }
//            
//TextField("entre the message ", text: $watchMessage)
//              Button("Send Data to Watch") {
//               sendMessagetoWatch()
//              }
//              .padding()
//          } .onAppear(perform: {
//activatewatch()
//})
//      }
//}

#Preview {
    wactchConnectivityView()
}

