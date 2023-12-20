//
//  ContentView.swift
//  WatchExtension Watch App
//
//  Created by John on 19/12/23.
//

import SwiftUI
import Foundation
import WatchConnectivity
import Combine
//MARK: get data form the iphone

//struct ContentView: View {
//    @State private var receivedMessage: String = "No message"
//    @ObservedObject var watchConnector = WatchConnector()
//    @State var message = ""
//    @State var cancellables: Set<AnyCancellable> = []
//    
//    //MARK:  GET MESSAGE WITH FUNCTION REFRESH
//    func getMEssageFromIphone(){
//        if let storagerecived = UserDefaults.standard.string(forKey: "message"){
//            self.message = storagerecived.description
//        }else{
//            self.message = ""
//            print("could not get message form watch memory")
//        }
//    }
//    //MARK: VIEW TO MANAGE THE WACTH SCREEN
//    var body: some View {
//           VStack {
//               if (self.message == ""){
//                   Text("No Message recived form iphone")
//                       
//               }
//               else{
//                   Text("DATA:" + message)
//               }
////MARK: CALL THE GETMESSAGE FUNCTION FORM IPHONE FOR IF HANDEL WITH BUTTON
////               Button {
////                   getMEssageFromIphone()
////               } label: {
////                   Text("Refresh")
////               }
//
//                  
//            //MARK: HANDEL THE DATA WITH IF LISNNG THE DATA FOR I PHONE SEND
//               
//           }.onAppear {
//               // Start listening for changes
//               watchConnector.$receivedmessage
//                   .receive(on: RunLoop.main)
//                   .sink { newMessage in
//                       self.message = newMessage
//                   }
//                   .store(in: &cancellables)
//           }
//       }
//}

struct ContentView: View {
  
    @State private var watchMessage = ""
    var watchconnection = WatchConnectivityDelegate()
   //MARK: SEND THE  DATA FORM WATCH TO IPHONE
    func sendMessagetoWatch(){
        if self.watchconnection.session.isReachable{
         
            self.watchconnection.session.sendMessage(["message": String(self.watchMessage)], replyHandler: nil, errorHandler: { error in
                print("Watch ERROR SENDING MESSGA E - " + error.localizedDescription)
            })
           
        }else{
            print("watch is NOT connected")
         
        }
    }
    var body: some View {
          VStack {
             
            
TextField("entre the message ", text: $watchMessage)
              Button("Send Data to Watch") {
               sendMessagetoWatch()
              }
              .padding()
          }
      }
}

#Preview {
    ContentView()
}
