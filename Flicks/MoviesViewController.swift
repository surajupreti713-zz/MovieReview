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
    
    var endPoint: String?
    var loadingMoreView: InfiniteScrollActivityView?
    var isMoreDataLoading = false
    var page: Int = 2
    
    @IBOutlet weak var navBarFirstPage: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        if endPoint == "now_playing" {
            navBarFirstPage.title = "Now Playing"
        }
        else if endPoint == "top_rated" {
            navBarFirstPage.title = "Top Rated"
        }
        
        errorView.isHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //animation is loaded
        MBProgressHUD.showAdded(to: self.view, animated: true)
        requestNetwork() // call for the http call
        MBProgressHUD.hide(for: self.view, animated: true)
        
        //will refresh when pulled
        refreshControl.tintColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // this will set up infinite scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                loadMoreData()
            }
        }
    }
    
    func loadMoreData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endPoint!)?api_key=\(apiKey)&page=\(page)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (data, response, error) in
            self.isMoreDataLoading = false
            self.loadingMoreView!.stopAnimating()
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
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endPoint!)?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.movies = dataDictionary["results"] as? [NSDictionary]
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
            else{
                self.errorView.isHidden = false
                
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = movies?[indexPath.row]
        let title = movie?["title"] as! String
        let overview = movie?["overview"] as! String
        let posterPath = movie?["poster_path"] as! String
        let baseUrl = "https://image.tmdb.org/t/p/w500/"
        let imageUrl = NSURL(string: baseUrl + posterPath)
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWith(imageUrl as! URL)
        cell.selectionStyle = .none
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    }
    

    
}
