//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Arthur Burgin on 3/29/17.
//  Copyright © 2017 Arthur Burgin. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var errorView: UIView!
    @IBOutlet var tableView: UITableView!
    
    var endpoint: String!
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        errorView.isHidden = true
        
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=45117f2cb86205671669a8ab94d64f81")

        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    //print("response: \(responseDictionary)")
                    
                    self.movies = (responseDictionary["results"] as! [NSDictionary])
                    self.tableView.reloadData()
                }
            }else{
                self.errorView.isHidden = false
            }
            
            MBProgressHUD.hide(for: self.view, animated: true)
        });
        task.resume()
        
        
    }
    
    func getApiKey()->String{
        var api = ""
        if let path = Bundle.path(forResource: "Info", ofType: "plist", inDirectory: "Flicks"){
            print(path)
            if let dic = NSDictionary(contentsOfFile: path){
                api = dic["theMovieDB_APIKey"] as! String
            }
        }
        return api

    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=45117f2cb86205671669a8ab94d64f81")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    //print("response: \(responseDictionary)")
                    
                    self.errorView.isHidden = true
                    
                    self.movies = (responseDictionary["results"] as! [NSDictionary])
                    self.tableView.reloadData()
                }
            }
            refreshControl.endRefreshing()
            MBProgressHUD.hide(for: self.view, animated: true)
        });
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let movies = movies{
            return movies.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let baseURL = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String{
        
            let posterURL = NSURL(string: baseURL + posterPath)! as URL
            cell.posterView.setImageWith(posterURL)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let destinationViewController = segue.destination as! MoviesDetailViewController
        destinationViewController.movie = movie
        
     }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
