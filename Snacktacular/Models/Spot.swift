//
//  Spot.swift
//  Snacktacular
//
//  Created by Thomas Park on 4/4/22.
//

import Foundation
import Firebase
import MapKit

class Spot: NSObject, MKAnnotation {
    var name: String
    var address: String
    var coordinate: CLLocationCoordinate2D
    var averageRating: Double
    var numberOfReviews: Int
    var postingUserID: String
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["name": name, "address": address, "latitude": latitude, "longtitude": longtitude, "averageRating": averageRating, "numberofReviews": numberOfReviews, "postingUserID": postingUserID, "documentID": documentID]
    }
    
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    var longtitude: CLLocationDegrees {
        return coordinate.longitude
    }
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longtitude)
    }
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return address
    }
    
    init(name: String, address: String, coordinate: CLLocationCoordinate2D, averageRating: Double, numberOfReviews: Int , postingUserID: String, documentID: String) {
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews
        self.postingUserID = postingUserID
        self.documentID = documentID
    
}
    
        convenience override init() {
            self.init(name: "", address: "", coordinate: CLLocationCoordinate2D(), averageRating: 0.0, numberOfReviews: 0, postingUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let address = dictionary["address"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! Double? ?? 0.0
        let longtitude = dictionary["longtitude"] as! Double? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
        let averageRating = dictionary["averageRating"] as! Double? ?? 0.0
        let numberOfReviews = dictionary["numberOfReviews"] as! Int? ?? 0
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
            self.init(name: name, address: address, coordinate: coordinate, averageRating: averageRating, numberOfReviews: numberOfReviews, postingUserID: postingUserID, documentID: "")
    }
    
    func saveData(completion: @escaping (Bool) ->()) {
        let db = Firestore.firestore()
        guard let postingUserID = Auth.auth().currentUser?.uid else {
            print("Error")
            return completion(false)
        }
        self.postingUserID = postingUserID
        let dataToSave: [String: Any] = self.dictionary
        
        if self.documentID == "" {
            var ref: DocumentReference? = nil
            ref = db.collection("spots").addDocument(data: dataToSave){ (error) in
                guard error == nil else {
                    print("ERROR: \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("Added Document: \(self.documentID)")
                completion(true)
            }
        }  else {
            let ref = db.collection("spots").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: \(error!.localizedDescription)")
                    return completion(false)
        }
                print("Updated Document: \(self.documentID)")
                completion(true)
        }
    }
}
    
    func updateAverageRating(completed: @escaping() -> ()) {
        let db = Firestore.firestore()
        let reviewsRef = db.collection("spots").document(documentID).collection("reviews")
        reviewsRef.getDocuments { (querySnapshot, error) in
            guard error == nil else {
                print ("error")
                return
            }
            return completed()
        }
        var ratingTotal = 0.0
        for document in querySnapshot!.documents {
            let reviewDictionary = document.data()
            let rating = reviewDictionary["rating"] as! Int? ?? 0
            ratingTotal = ratingTotal + Double(rating)
        }
        self.averageRating = ratingTotal / Double(querySnapshot!.count)
        self.numberOfReviews = querySnapshot!.count
        let dataToSave = self.dictionary
        let spotRef = db.collection("spots").document(self.documentID)
        spotRef.setData(dataToSave) {(error) in
            if let error = error {
                print ("Error")
                completed()
            } else {
                print ("new average")
                completed()
            }
        }
    }
}
