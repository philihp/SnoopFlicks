//
//  MoviesViewController.swift
//  SnoopFlicks
//
//  Created by Philihp Busby on 2016-05-16.
//  Copyright © 2016 Philihp Busby. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var stylerControl: UISegmentedControl!
    
    var refreshControl: UIRefreshControl!
    
    var movies: [NSDictionary]?
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        refreshControlAction(refreshControl)
        
        // Display the loading HUD for the initial load (not forced refreshes)
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        setConnection(true)
        
        // Just set the current style to default
        stylerChange("")
    }
    
    @IBAction func stylerChange(sender: AnyObject) {
        if(stylerControl.selectedSegmentIndex == 0) {
            tableView.hidden = false
            collectionView.hidden = true
        }
        else {
            tableView.hidden = true
            collectionView.hidden = false
        }
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        let apiKey = "d28a8417cb5c25827c656d051946f4a0"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(
            request,
            completionHandler: { (dataOrNil, response, error) in
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                        
                        // Update data source with new data
                        self.movies = (responseDictionary["results"] as! [NSDictionary])
                    
                        // Hide the network error, if it is displayed.
                        self.setConnection(true)
                    }
                }
                else {
                    // show network error
                    self.setConnection(false)
                }
                
                // Reload tableView
                self.tableView.reloadData()
                self.collectionView.reloadData()
                
                // Stop spinning the refresh
                refreshControl.endRefreshing()
                
                // Hide the loading HUD
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            }
        )
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MoviesViewCell", forIndexPath: indexPath) as! MovieCell
        let movie = movies![indexPath.row]
        
        let title = movie["title"] as! String
        cell.titleLabel.text = title
        
        let overview = movie["overview"] as! String
        cell.overviewLabel.text = overview
        
        let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: posterBaseUrl + posterPath)
            cell.posterView.setImageWithURL(imageUrl!)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PosterViewCell", forIndexPath: indexPath) as! PosterCell
        let movie = movies![indexPath.row]
        
        let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: posterBaseUrl + posterPath)
            cell.posterImage.setImageWithURL(imageUrl!)
        }
        
        return cell
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tableCell = sender as? UITableViewCell {
            let indexPath = tableView.indexPathForCell(tableCell)
            let movie = movies![indexPath!.row]
            
            let detailViewController = segue.destinationViewController as! DetailViewController
            detailViewController.movie = movie
            
            tableCell.selected = false
        }
        else if let collectionCell = sender as? UICollectionViewCell {
            let indexPath = collectionView.indexPathForCell(collectionCell)
            let movie = movies![indexPath!.row]
            
            let detailViewController = segue.destinationViewController as! DetailViewController
            detailViewController.movie = movie
            
            collectionCell.selected = false
        }

        
    }
    
    func setConnection(live: Bool) {
        if(live) {
            errorView.hidden = true
            errorView.frame = CGRectMake(0,0, 320, 0)
        }
        else {
            errorView.hidden = false
            errorView.frame = CGRectMake(0,0, 320, 50)
        }
    }

}
