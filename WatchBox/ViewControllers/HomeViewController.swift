//
//  HomeViewController.swift
//  WatchBox
//
//  Created by Iyinoluwa Tugbobo on 3/28/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Alamofire
import Nuke


class HomeViewController: UIViewController, UICollectionViewDataSource {

    var db: Firestore!
    

    var currUser: User?
    
    let key: String = "32d3d96bbd7c27a2ebe60ebeb83393c9"
    var page: Int = 1
    
    @IBOutlet weak var popularCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionView: UICollectionView!
    @IBOutlet weak var topCollectionView: UICollectionView!
    var popularShows: [Show] = []
    var newShows: [Show] = []
    var topShows: [Show] = []
    var genres: [String] = []
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case popularCollectionView:
            return popularShows.count
        case newCollectionView:
            return newShows.count
        case topCollectionView:
            return topShows.count
        default:
            return 0
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            collectionView.deselectItem(at: indexPath, animated: true)
     }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == popularCollectionView {
            let show = popularShows[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popular", for: indexPath) as! PopularViewCell
            
            guard show.poster_path != nil else { return cell }
            let posterURL = "https://image.tmdb.org/t/p/original/" + show.poster_path!
            Nuke.loadImage(with: URL(string: posterURL)!, into: cell.posterView)
            
            cell.show = show
            return cell
            
        } else if collectionView == newCollectionView {
            let show = newShows[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "new", for: indexPath) as! NewViewCell
            
            guard show.poster_path != nil else { return cell }
            let posterURL = "https://image.tmdb.org/t/p/original/" + show.poster_path!
            Nuke.loadImage(with: URL(string: posterURL)!, into: cell.posterView)
            
            cell.show = show
            return cell
            
        } else {
            let show = topShows[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "top", for: indexPath) as! TopViewCell
            
            guard show.poster_path != nil else { return cell }
            let posterURL = "https://image.tmdb.org/t/p/original/" + show.poster_path!
            Nuke.loadImage(with: URL(string: posterURL)!, into: cell.posterView)
            
            cell.show = show
            return cell
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        prepareCollectionViews()
        attachAuthListener()
        setupUI()
        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard
            Auth.auth().currentUser != nil
        else {
            print("❌ No user is currently signed in.")
            self.performSegue(withIdentifier: "showLogin", sender: nil)
            return
        }
        currUser = Auth.auth().currentUser
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "detailA":
            let cell = sender as! NewViewCell
            let index = newCollectionView.indexPathsForSelectedItems?.first
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.id = newShows[index!.row].id
        case "detailB":
            let cell = sender as! PopularViewCell
            let index = popularCollectionView.indexPathsForSelectedItems?.first
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.id = popularShows[index!.row].id
        case "detailC":
            let cell = sender as! TopViewCell
            let index = topCollectionView.indexPathsForSelectedItems?.first
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.id = topShows[index!.row].id
        default:
            print("No show data.")
        }
    }

    
    func setupUI() {
//        usernameLabel.text = currUser?.displayName
    }
    
    func prepareCollectionViews() {
        popularCollectionView.dataSource = self
        newCollectionView.dataSource = self
        topCollectionView.dataSource = self
        
        newCollectionView.allowsMultipleSelection = false
        popularCollectionView.allowsMultipleSelection = false
        topCollectionView.allowsMultipleSelection = false
        
        let pLayout = popularCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let nLayout = newCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let tLayout = topCollectionView.collectionViewLayout as! UICollectionViewFlowLayout

    }
    
    func attachAuthListener() {
        // Adds auth state change listener to transition back to auth if state changes
        let handle = Auth.auth().addStateDidChangeListener { auth, user in
            guard user == nil else {
                self.currUser = user
                print("👤 \(self.currUser!.email!) is currently signed in.")
                self.setupUI()
                return
            }
        }
    }
    
    func requestData() {
        let newURL = "https://api.themoviedb.org/3/tv/airing_today?api_key=\(key)&page=\(page)&sort_by=popularity.desc&with_origin_country=US"
        let popularURL = "https://api.themoviedb.org/3/tv/popular?api_key=\(key)&page=\(page)&with_origin_country=US"
        let topURL = "https://api.themoviedb.org/3/tv/top_rated?api_key=\(key)&page=\(page)&with_origin_country=US"
        var ids: [Int] = []
        
        AF.request(popularURL).responseDecodable(of:TMDBResponse.self) {response in
            guard let res = response.value else {return}
            self.popularShows = res.results
            for show in res.results {
                ids.append(show.id)
            }
            self.popularCollectionView.reloadData()
        }
        
        AF.request(newURL).responseDecodable(of:TMDBResponse.self) {response in
            guard let res = response.value else {return}
            self.newShows = res.results
            for show in res.results {
                ids.append(show.id)
            }
            self.newCollectionView.reloadData()
        }
        
        AF.request(topURL).responseDecodable(of:TMDBResponse.self) {response in
            guard let res = response.value else {return}
            self.topShows = res.results
            for show in res.results {
                ids.append(show.id)
            }
            self.topCollectionView.reloadData()
        }
        
        db.collection("activity").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var docIDs: [Int] = []
                for document in querySnapshot!.documents {
                    docIDs.append(Int(document.documentID)!)
                }
                print("Adding new shows to database.")
                for id in ids {
                    if !(docIDs.contains(id)) {
                        self.db.collection("activity").document("\(id)").setData([
                            "likes": 0,
                            "views": 0
                        ]) {err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func handleLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "showLogin", sender: nil)
            print("⬅️ \(currUser!.email!) has just logged out!")
        } catch let err as NSError {
            print("❌ Sign out error: \(err)")
        }
    }

}
