//
//  SnackUsers.swift
//  Snacktacular
//
//  Created by Thomas Park on 4/25/22.
//

import Foundation
import Firebase

class SnackUsers {
    var userArray: [SnackUser]  = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print ("Error")
                return completed()
            }
            self.userArray = []
            for document in querySnapshot!.documents {
                let snackUser = SnackUser(dictionary: document.data())
                snackUser.documentID = document.documentID
                self.userArray.append(snackUser)
            }
            completed()
        }
    }
}
