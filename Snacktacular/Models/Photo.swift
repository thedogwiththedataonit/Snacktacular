//
//  Photo.swift
//  Snacktacular
//
//  Created by Thomas Park on 4/25/22.
//

import UIKit
import Firebase

class Photo {
    var image: UIImage
    var description: String
    var photoUserID: String
    var photoUserEmail: String
    var date: Date
    var photoURL: String
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["description": description, "photoUserID": photoUserID, "photoUseremail": photoUserEmail, "date": timeIntervalDate, "photoURL": photoURL]
    }
    
    init (image: UIImage, description: String, photoUserID: String, photoUserEmail: String, date: Date, photoURL: String, documentID: String) {
        self.image = image
        self.description = description
        self.photoUserID = photoUserID
        self.photoUserEmail = photoUserEmail
        self.date = date
        self.photoURL = photoURL
        self.documentID = documentID
        
    }

    convenience init() {
        let photoUserID = Auth.auth().currentUser?.uid ?? ""
        let photoUserEmail = Auth.auth().currentUser?.email ?? "unknown email"
        self.init(image: UIImage(), description: "", photoUserID: photoUserID, photoUserEmail: photoUserEmail, date: Date(), photoURL: "", documentID: "")
    }
    convenience init(dictionary: [String: Any]) {
        
        
        let description = dictionary["description"] as! String? ?? ""
        let photoUserID = dictionary["photoUserID"] as! String? ?? ""
        let photoUserEmail = dictionary["photoUserEmail"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let photoURL = dictionary["photoURL"] as! String? ?? ""


        self.init(image: UIImage(), description: description, photoUserID: photoUserID, photoUserEmail: photoUserEmail, date: date, photoURL: photoURL, documentID: "")
    }
    
    func saveData(spot: Spot, completion: @escaping (Bool) ->()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print ("Error")
            return
        }
        
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        if documentID == "" {
            documentID = UUID().uuidString
        }
        
        let storageRef = storage.reference().child(spot.documentID).child(documentID)
        
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetaData) { (metadata, error) in
            if let error = error {
                print ("Error")
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            print ("Upload successful")
            
            storageRef.downloadURL { (url, error) in
                guard error == nil else {
                    print ("error")
                    return completion(false)
                }
                guard let url = url else {
                    print ("Error")
                    return completion(false)
                }
                self.photoURL = "\(url)"
                
                let dataToSave = self.dictionary
                let ref = db.collection("spots").document(spot.documentID).collection("photos").document(self.documentID)
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
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print ("error")
            }
            completion(false)
        }
        
        
    }
    
    func loadImage(spot: Spot, completion: @escaping (Bool) -> ()){
        guard spot.documentID != "" else {
            print ("Error")
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference().child(spot.documentID).child(documentID)
        storageRef.getData(maxSize: 25*1024*1024) { (data, error) in
            if let error = error {
                print ("error")
                return completion(false)
            } else {
                self.image = UIImage(data: data!) ?? UIImage()
                return completion(true)
            }
        }
    }
}
