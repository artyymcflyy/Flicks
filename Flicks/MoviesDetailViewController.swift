//
//  MoviesDetailViewController.swift
//  Flicks
//
//  Created by Arthur Burgin on 3/31/17.
//  Copyright © 2017 Arthur Burgin. All rights reserved.
//

import UIKit

class MoviesDetailViewController: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var overviewLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var infoView: UIView!
    
    var movie: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarHeight = tabBarController!.tabBar.frame.size.height
        
        let title = movie!["title"] as! String
        titleLabel.text = title
        
        let overview = movie!["overview"] as! String
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        
        //set view position x and make height fit to context
        infoView.frame.origin.y = posterImageView.frame.size.height - ((titleLabel.frame.size.height + overviewLabel.frame.size.height + tabBarHeight+50)/2)
        infoView.frame.size.height = titleLabel.frame.size.height + overviewLabel.frame.size.height+tabBarHeight + 50
        
        let smallPosterBaseURL = "https://image.tmdb.org/t/p/w185"
        let largePosterBaseURL = "https://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie!["poster_path"] as? String{
            let smallPosterURLRequest = URLRequest(url: NSURL(string: smallPosterBaseURL + posterPath)! as URL)
            let largePosterURLRequest = URLRequest(url: NSURL(string: largePosterBaseURL + posterPath)! as URL)
            posterImageView.setImageWith(smallPosterURLRequest, placeholderImage: nil, success:{(posterURLRequest, posterURLResponse, smallImage)->Void in
                self.posterImageView.alpha = 0.0
                self.posterImageView.image = smallImage
                
                UIView.animate(withDuration: 0.3, animations: {()-> Void in
                    self.posterImageView.alpha = 1.0
                }, completion: {(success)->Void in
                    self.posterImageView.setImageWith(largePosterURLRequest, placeholderImage: smallImage, success: {(largePosterURLRequest, largePosterURLResponse, largeImage)->Void in
                            self.posterImageView.image = largeImage
                    }, failure: {(largePosterURLRequest, largePosterURLResponse, largeImage)->Void in})
                })
            }, failure:{(posterURLRequest, posterURLResponse, image)->Void in})
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
