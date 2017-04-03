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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet var errorView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    var endpoint: String!
    var movies: [NSDictionary]?
    var resultsArr: [NSDictionary]?
    var tempArr:[NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tabBarController?.tabBar.barTintColor = UIColor.black
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.delegate = self
        searchBar.setShowsCancelButton(false, animated: true)
        
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
                    self.tempArr = self.movies
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
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let resultArr = movies?.filter { String(describing: $0["title"]).range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil}
        
        if let results = resultArr{
            if results.count > 0{
                movies = results
            }
        }
        
        if searchText.isEmpty{
            movies = tempArr
        }
        
        tableView.reloadData()
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
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
        
            let posterURLRequest = URLRequest(url: NSURL(string: baseURL + posterPath)! as URL)
            
            cell.posterView.setImageWith(posterURLRequest, placeholderImage: nil, success:{(posterURLRequest, posterURLResponse, image)->Void in
                // image was not cached
                if posterURLResponse != nil{
                    cell.posterView.alpha = 0.0
                    cell.posterView.image = image
                    UIView.animate(withDuration: 0.3, animations: {()->Void in
                        cell.posterView.alpha = 1.0
                    })
                }else{
                    //image was cached
                    cell.posterView.image = image 
                }
            }, failure:{(posterURLRequest, posterURLResponse, error) -> Void in})
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searchBar.resignFirstResponder()
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
