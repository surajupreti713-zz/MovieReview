//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Suraj Upreti on 2/6/17.
//  Copyright © 2017 Suraj Upreti. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var movies: [NSDictionary]?
    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.dataSource = self
        tableView.delegate = self     //this will confirm the delegate for the table view
        
        createSearchBar()
        
        requestNetwork()
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        requestNetwork()
    }
    
    func requestNetwork() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        MBProgressHUD.showAdded(to: self.tableView, animated: true)    //this will show the loading icon before loading the page
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            MBProgressHUD.hide(for: self.tableView, animated: true)   //this will hide the loading icon after the page is loaded
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.movies = dataDictionary["results"] as! [NSDictionary]
                    self.tableView.reloadData()
                    
                }
                
            }
            self.refreshControl.endRefreshing()
        }
        task.resume()
    }
    
    func createSearchBar() {                 //this function will create a search bar manually
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Enter your search here"
        searchBar.delegate = self               //confirms the delegate property for the search bar
        
        self.navigationItem.titleView = searchBar       //this will set the search bar at the navigation bar
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count                     //returns the total number of items in movies array
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let posterPath = movie["poster_path"] as! String
        let baseUrl = "https://image.tmdb.org/t/p/w500/"
        let imageUrl = NSURL(string: baseUrl + posterPath)      //creates a URL image
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWith(imageUrl as! URL)
        return cell
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}
