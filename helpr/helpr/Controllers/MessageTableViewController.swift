//
//  MessageTableViewController.swift
//  helpr
//
//  Created by Critical on 2019-02-05.
//  Copyright © 2019 ryan.konynenbelt. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

class MessageTableViewController: UITableViewController {
    var mPreviews = [MessagePreview]()
    var db = Firestore.firestore()
    var database = DatabaseHelper()
    var userID = Auth.auth().currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPreviews(notification:)), name: NSNotification.Name(rawValue: "reloadMessagePreviews"), object: nil)
        
        //loadSampleMessagePreviews()
        
        // load in message previews based on active conversations user is a part of
        db.collection("users").document(userID!).collection("conversations").order(by: "jobID", descending: true)
            .addSnapshotListener { querySnapshot, error in
            var job: Job?
            guard let snapshot = querySnapshot else {
                print("Error fetching conversations snapshots: \(String(describing: error))")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    let active = diff.document.data()["active"] as! Bool
                    print("entered")
                    
                    if (active) {
                        let chatID = diff.document.data()["chatID"] as! String
                        let partnerName = diff.document.data()["chatPartnerName"] as! String
                        let chatPartnerID = diff.document.data()["chatPartnerID"] as! String
                        let partnerPicRef = diff.document.data()["chatPartnerPicRef"] as! String
                        
                        var msgPreview = MessagePreview()
                        let jobFBID = diff.document.data()["jobFirebaseID"] as? String
                        if (jobFBID != nil) {
                            self.db.collection("jobs").document(jobFBID!).getDocument { (document, err) in
                                if let document = document, document.exists {
                                    job = Job (
                                        title: document.data()?["title"]! as! String,
                                        category: document.data()?["category"]! as! String,
                                        description: document.data()?["description"]! as! String,
                                        pictureURLs: document.data()?["pictureURLs"]! as! [String],
                                        tags: ["#iPhone", "#Swift", "#Apple"],
                                        address: document.data()?["address"]! as! [String : String],
                                        location: document.data()?["location"]! as! GeoPoint,
                                        anonLocation: document.data()?["anonLocation"]! as! GeoPoint,
                                        distance: 0,
                                        postalCode: "T3A 1B6",
                                        postedTime: document.data()?["postedTime"]! as! Date,
                                        email: document.data()?["posterID"]! as! String,
                                        firebaseID: document.documentID,
                                        id: document.data()?["id"]! as! Int)
                                }
                                
                                msgPreview?.partnerID = chatPartnerID
                                msgPreview?.partnerPicRef = partnerPicRef
                                msgPreview?.senderName = partnerName
                                msgPreview?.chatID = chatID
                                msgPreview?.job = job
                                
                                self.mPreviews.append(msgPreview!)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.database.getBidAmt(chatID: chatID, chatPartnerID: chatPartnerID) { (bid, accepted) in
                                let index = self.mPreviews.firstIndex(where: { (mPreview) -> Bool in
                                    mPreview.chatID == chatID
                                })
                                
                                self.mPreviews[index!].bidAmt = bid
                                self.mPreviews[index!].accepted = accepted
                                self.database.getMsgPreview(chatID: chatID) { (content, created, senderName) in
                                    self.mPreviews[index!].mPreview = content
                                    self.mPreviews[index!].mTime =  created.timeAgoSinceDate(currentDate: Date(), numericDates: true)
                                    
                                    // only reload table view once, not for every new message preview it finds
                                    self.timer?.invalidate()
                                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                                }
                            }
                        }
                        
                        // reload message preiew on new message exchanged in chat log
                        self.db.collection("chats").document(chatID).collection("messages").order(by: "created", descending: true).addSnapshotListener { querySnapshot, error in
                            guard let snapshot = querySnapshot else {
                                print("Error fetching latest preview snapshots: \(String(describing: error))")
                                return
                            }
                            var accepted = false
                            
                            //let mPreview = self.mPreviews.filter{$0.chatID == chatID}.first
                            let index = self.mPreviews.firstIndex(where: { (mPreview) -> Bool in
                                mPreview.chatID == chatID
                            })
                            if (index != nil) {
                                snapshot.documentChanges.forEach { diff in
                                    if (diff.type == .added) {
                                        DispatchQueue.main.async {
                                            self.database.getBidAmt(chatID: chatID, chatPartnerID: chatPartnerID) { (bid, accepted) in
                                                self.mPreviews[index!].bidAmt = bid
                                                self.mPreviews[index!].accepted = accepted
                                                self.mPreviews[index!].mPreview = diff.document.data()["content"] as! String
                                                let created = diff.document.data()["created"] as! Date
                                                self.mPreviews[index!].mTime = created.timeAgoSinceDate(currentDate: Date(), numericDates: true)
                                                DispatchQueue.main.async(execute: {
                                                    print("we reloaded the table")
                                                    self.tableView.reloadData()
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        DispatchQueue.main.async(execute: {
            print("we reloaded the table")
            self.tableView.reloadData()
        })
    }
    
    // reload on new message preview added
    @objc func reloadPreviews(notification: NSNotification){
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mPreviews.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "MessagePreviewTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MessagePreviewTableViewCell else {
            fatalError("The dequeued cell is not an instance of HomeTableVieCell")
        }
        
        let preview : MessagePreview
        preview = mPreviews[indexPath.row]
        
        cell.lblName.text = preview.senderName
        cell.lblMsgPreview.text = preview.mPreview
        
        if (preview.picture != nil) {
            cell.ivProfilePic.image = preview.picture
        } else {
            // get other user's image from database, use default picture if an error occurs
            let storageRef = Storage.storage().reference()
            let ref = storageRef.child("profilePictures").child(preview.partnerID).child(preview.partnerPicRef)
            let phImage = UIImage(named: "jobDefault.png")
            cell.ivProfilePic.sd_setImage(with: ref, placeholderImage: phImage)
        }
        
        cell.lblBidAmt.text = preview.bidAmt
        cell.lblMsgTime.text = preview.mTime

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (mPreviews[indexPath.row].accepted) {
            //performSegue(withIdentifier: "showChat", sender: tableView.cellForRow(at: indexPath))
            let uID = mPreviews[indexPath.row].partnerID
            
            let chatLogController = storyboard!.instantiateViewController(withIdentifier: "ChatLogController") as! ChatLogController
            chatLogController.chatID = mPreviews[indexPath.row].chatID
            chatLogController.partnerID = uID
            chatLogController.partnerName = mPreviews[indexPath.row].senderName
            chatLogController.partnerPicRef = mPreviews[indexPath.row].partnerPicRef
            let navigationController = UINavigationController(rootViewController: chatLogController)
            self.navigationController?.pushViewController(chatLogController, animated: true)
        }
        else {
            let bidViewController = storyboard?.instantiateViewController(withIdentifier: "BidViewController") as! BidViewController
            bidViewController.job = mPreviews[indexPath.row].job
            bidViewController.chatID = mPreviews[indexPath.row].chatID
            let navigationController = UINavigationController(rootViewController: bidViewController)
            navigationController.setNavBarAttributes()
            present(navigationController, animated: true)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - Navigation
}
