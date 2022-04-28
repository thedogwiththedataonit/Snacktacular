//
//  Photos.swift
//  Snacktacular
//
//  Created by Thomas Park on 4/25/22.
//

import Foundation
import Firebase

class Photos {
    var photoArray: [Photo] = []
    
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    func loadData(spot: Spot, completed: @escaping () -> ()) {
        guard spot.documentID != "" else {
            return
        }
        db.collection("spots").document(spot.documentID).collection("photos").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: \(error!.localizedDescription)")
                return completed()
            }
            self.photoArray = []
            for document in querySnapshot!.documents {
                let photo = Photo(dictionary: document.data())
                photo.documentID = document.documentID
                self.photoArray.append(photo)
            }
            completed()
    }
    }
    
    
    
    
}
