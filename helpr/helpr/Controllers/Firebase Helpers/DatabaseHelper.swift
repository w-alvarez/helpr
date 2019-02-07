//
//  Database.swift
//  helpr
//
//  Created by Hilmi Abou-Saleh on 2018-11-22.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
//

import Firebase
import CodableFirebase

class DatabaseHelper {
    var ref: DatabaseReference!
    var storage = StorageHelper()
    var docRef: DocumentReference!
    var db: Firestore!
    var jobs: [Job]
    init() {
        ref = Database.database().reference()
        db = Firestore.firestore()
        jobs = [Job]()
    }
    
    func createUser(email: String, password: String, completion: @escaping (Error?) -> ()){
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error == nil {
                print("Creating user: " + (user?.user.email)!)
                completion(nil)
            }else{
                print("Cannot create account" + error.debugDescription)
                completion(error)
            }
        }
    }
    
    func addUserInformation(dataToSave: [String: Any], photoURL: String?, completion: @escaping (Error?) -> ()) {
        let userID = Auth.auth().currentUser?.uid
        docRef = db.collection("users").document(userID!)
        docRef.setData(dataToSave) { (error) in
            if error != nil {
                print("Error adding data to users collection")
                completion(nil)
            }else{
                print("Data has been successfully added!")
                completion(error)
            }
        }
//        if let user = user {
//            let changeRequest = user.createProfileChangeRequest()
//
//            changeRequest.displayName = name
//            if photoURL != nil {
//                changeRequest.photoURL =
//                    NSURL(string: photoURL!)! as URL
//            }
//
//            changeRequest.commitChanges { error in
//                if error == nil {
//                    completion(nil)
//                }else{
//                    print("Cannot add to account" + error.debugDescription)
//                    completion(error)
//                }
//            }
//        }
    }
    
    func getUser(completion: @escaping (DocumentSnapshot?) -> () ) {
        let userID = Auth.auth().currentUser?.uid
        docRef = db.collection("users").document(userID!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let userData = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(userData)")
                completion(document)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func writeJob(job:Job) {
        let data = try! FirebaseEncoder().encode(job.information)
        self.ref.child("jobs").child(job.information.id).setValue(data)

    }
    
    func readJobs(completion: @escaping ([Job]) -> ()){
        var jobs = [Job]()
        ref.child("jobs").queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            for snap in snapshot.children.allObjects as! [DataSnapshot] {
                if snap.exists() {
                    if let dict = snap.value as? [String: Any] {
                        let jobInformation = try! FirebaseDecoder().decode(JobInformation.self, from: dict)
                        let job = Job(jobInformation: jobInformation)
                        let storage = StorageHelper()
                        storage.loadImages(job: job!)
                        jobs.append(job!)
                    }
                }
            }
            completion(jobs)
        })
        { (error) in
            print(error.localizedDescription)
        }
    }

//    func getLatestJobFromFirebase(completion: @escaping (_ job:[Dictionary<String, Any>]) -> Swift.Void)
//    {
//        ref.child("jobs").queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            for snap in snapshot.children.allObjects as! [DataSnapshot] {
//                if snap.exists() {
//                    if let dict = snap.value as? [String: Any] {
//                        completion(dict)
//                    }
//                }
//            }
//        })
//        { (error) in
//            print(error.localizedDescription)
//        }
//
//    }
//
}
