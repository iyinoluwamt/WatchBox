//
//  DetailViewController.swift
//  WatchBox
//
//  Created by Iyinoluwa Tugbobo on 3/29/23.
//

import UIKit
import Nuke
import Alamofire
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth


class DetailViewController: UIViewController {

    var id: Int?
    let imageBase = "https://image.tmdb.org/t/p/original/"
    let key: String = "32d3d96bbd7c27a2ebe60ebeb83393c9"
    var details: DetailResponse?
    
    var liked: Bool?
    var viewed: Bool?
    var reviewed: Bool?
    var bookmarked: Bool?
    
    let userID = Auth.auth().currentUser!.uid
    
    var db: Firestore!
    var activityRef: CollectionReference?
    var userRef: DocumentReference?
    let increment = FieldValue.increment(Int64(1));
    let decrement = FieldValue.increment(Int64(-1));
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var backdropView: UIImageView!
    @IBOutlet weak var networkLogoView: UIImageView!
    @IBOutlet weak var firstAirLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var viewButton: UIButton!
    
    @IBOutlet weak var viewsCount: UILabel!
    @IBOutlet weak var likesCount: UILabel!
    
    @IBAction func handleLike(_ sender: Any) {

        print("\nMutating for showID \(id!)")
        
        let batch = db.batch()
        if liked! {
            let activityDoc = activityRef!.document("\(id!)")
            let likedShowDoc = userRef!.collection("likes").document("\(self.id!)")
            
            batch.updateData([
                "likes": decrement
            ], forDocument: activityDoc)
            batch.deleteDocument(likedShowDoc)
            
            batch.commit() {err in
                if let err = err {
                    print("❌ ERROR: \(err)")
                } else {
                    print("✅ SUCCES: Batch write successful.")
                }
            }
            liked = false
            toggleLike()
        } else {
            let activityDoc = activityRef!.document("\(id!)")
            let likedShowDoc = userRef!.collection("likes").document("\(self.id!)")
            
            batch.updateData([
                "likes": increment
            ], forDocument: activityDoc)
            batch.setData([
                "name": self.details!.name,
                "id": self.details!.id
            ], forDocument: likedShowDoc)
            
            batch.commit() {err in
                if let err = err {
                    print("❌ ERROR: \(err)")
                } else {
                    print("✅ SUCCES: Batch write successful.")
                }
            }
            liked = true
            toggleLike()
        }
    }
    
    @IBAction func handleView(_ sender: Any) {
        print("\nMutating for showID \(id!)")
        
        let batch = db.batch()
        if viewed! {
            let activityDoc = activityRef!.document("\(id!)")
            let likedShowDoc = userRef!.collection("viewed").document("\(self.id!)")
            
            batch.updateData([
                "views": decrement
            ], forDocument: activityDoc)
            batch.deleteDocument(likedShowDoc)
            
            batch.commit() {err in
                if let err = err {
                    print("❌ ERROR: \(err)")
                } else {
                    print("✅ SUCCES: Batch write successful.")
                }
            }
            viewed = false
            toggleView()
        } else {
            let activityDoc = activityRef!.document("\(id!)")
            let likedShowDoc = userRef!.collection("viewed").document("\(self.id!)")
            
            batch.updateData([
                "views": increment
            ], forDocument: activityDoc)
            batch.setData([
                "name": self.details!.name,
                "id": self.details!.id
            ], forDocument: likedShowDoc)
            
            batch.commit() {err in
                if let err = err {
                    print("❌ ERROR: \(err)")
                } else {
                    print("✅ SUCCES: Batch write successful.")
                }
            }
            viewed = true
            toggleView()
        }
    }
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        activityRef = db.collection("activity")
        userRef = db.collection("users").document(userID)
        
        userRef?.collection("likes").getDocuments() { (snapshot, err) in
            if let err = err {
               print("❌ ERROR: \(err)")
            } else {
                print("✅ SUCCESS: Loaded user likes")
                for doc in snapshot!.documents {
                    if doc.documentID == "\(self.id!)" {
                        self.liked = true
                        break
                    } else {
                        self.liked = false
                    }
                }
                if self.liked == nil {
                    self.liked = false
                }
                self.toggleLike()
            }
        }
        
        userRef?.collection("viewed").getDocuments() { (snapshot, err) in
            if let err = err {
               print("❌ ERROR: \(err)")
            } else {
                print("✅ SUCCESS: Loaded user viewed")
                for doc in snapshot!.documents {
                    if doc.documentID == "\(self.id!)" {
                        self.viewed = true
                        break
                    } else {
                        self.viewed = false
                    }
                }
                if self.viewed == nil {
                    self.viewed = false
                }
                self.toggleView()
            }
        }
        
        let showActivity = activityRef?.document("\(id!)")
        showActivity!.addSnapshotListener { snapshot, err in
            guard let doc = snapshot else {
                print("❌ ERROR: Did not retrieve document.")
                return
            }
            guard let data = doc.data() else {
                print("❌ ERROR: Document data was empty.")
                return
            }
            print("🔄 Change in activity data")
            
            let likes = data["likes"]! as! Int64
            let views = data["views"]! as! Int64
            
            self.likesCount.text = String(likes)
            self.viewsCount.text = String(views)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        requestShow()
    }
    
    func requestShow() {
        let url = "https://api.themoviedb.org/3/tv/\(id!)?api_key=\(key)"
        AF.request(url).responseDecodable(of:DetailResponse.self) {response in
            self.details = response.value
            self.setupUI()
        }
    }
    
    func setupUI() {
        guard
            details != nil
        else { return }

        let backdropURL = imageBase + (details?.backdrop_path)!
        Nuke.loadImage(with: URL(string: backdropURL)!, into: backdropView)
        let networkLogoURL = imageBase + (details?.networks[0].logo_path)!
        Nuke.loadImage(with: URL(string: networkLogoURL)!, into: networkLogoView)
        
        nameLabel.text = details?.name
        overviewLabel.text = details?.overview
        
        guard
            let sCount = details?.number_of_seasons,
            let firstAirDate = details?.first_air_date
        else {return}
        firstAirLabel.text = "\(firstAirDate)  |  \(sCount) Seasons"
        
        guard let genres = details?.genres.prefix(2) else {return}
        var genreString = ""
        
        for genre in genres {
            genreString += "\(genre.name)  |  "
        }
        genreString = String(genreString.dropLast(3))
        genreLabel.text = genreString
    }
    
    func toggleLike() {
        if self.liked! {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    func toggleView() {
        if self.viewed! {
            viewButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        } else {
            viewButton.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
