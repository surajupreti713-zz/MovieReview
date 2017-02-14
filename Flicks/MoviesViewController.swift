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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate{
    var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    
    
    var endPoint: String?
    var loadingMoreView: InfiniteScrollActivityView?
    var isMoreDataLoading = false
    var page: Int = 2
    
    ////////////////////////////////////////////
    @IBOutlet weak var navBarFirstPage: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        filteredMovies = movies;
        
        errorView.isHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        refreshControl.tintColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        createSearchBar()
        requestNetwork()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Handle scroll behavior here
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // ... Code to load more results ...
                loadMoreData()
            }
        }
    }
    
    func loadMoreData() {
        
        // ... Create the NSURLRequest (myRequest) ...
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endPoint!)?api_key=\(apiKey)&page=\(page)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (data, response, error) in
            
            // Update flag
            self.isMoreDataLoading = false
            
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            
            // ... Use the new data to update the data source ...
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    let responseData = dataDictionary["results"] as? [NSDictionary]
                    if let responseData = responseData {
                        self.movies! += responseData as [NSDictionary]
                        self.page += 1
                    }
                }
            }
            else {
                self.errorView.isHidden = false
            }
            // Reload the tableView now that there is new data
            self.tableView.reloadData()
        });
        task.resume()
    }
    
  
    func dismissKeyboard() {
        view.endEditing(true)
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
                self.errorView.isHidden = true
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.movies = dataDictionary["results"] as! [NSDictionary]
                    self.filteredMovies = self.movies
                    self.tableView.reloadData()
                }
            } else {
                self.errorView.isHidden = false
            }
            self.refreshControl.endRefreshing()
        }
        task.resume()
    }
    
    func createSearchBar() {                 //this function will create a search bar programmatically
        searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Enter your search here"
        searchBar.delegate = self               //confirms the delegate property for the search bar
        self.navigationItem.titleView = searchBar       //this will set the search bar at the navigation bar
        searchBar.showsCancelButton = true
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.filteredMovies = self.movies
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count                     //returns the total number of items in movies array
        } else {
            return 0
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        self.filteredMovies = searchText.isEmpty ? movies : movies?.filter({(movie: NSDictionary) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return (movie["title"] as? String)?.range(of: searchText, options: .caseInsensitive) != nil
        })
        tableView.reloadData()
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = self.filteredMovies![indexPath.row]
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {                              ///////////////////////////
        let indexPath = tableView.indexPathForSelectedRow
        let index = indexPath?.row
        let detailsViewController = segue.destination as! DetailViewController
        let movie = movies![index!]
        let title = movie["title"] as! String
        detailsViewController.movieTitle = title
        let releaseDate = movie["release_date"] as! String
        detailsViewController.releaseDate = releaseDate
        let overview = movie["overview"] as! String
        detailsViewController.textDetails = overview
        let rating = movie["vote_average"] as! Float
        detailsViewController.rating = rating
        let posterPath = movie["poster_path"] as! String
        let baseURL = "https://image.tmdb.org/t/p/w500/"
        let imageURLString = baseURL + posterPath
        detailsViewController.imageUrlString = imageURLString
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}
