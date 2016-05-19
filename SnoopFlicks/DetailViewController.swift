//
//  DetailViewController.swift
//  SnoopFlicks
//
//  Created by Philihp Busby on 2016-05-18.
//  Copyright © 2016 Philihp Busby. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var header: UINavigationItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = scrollView.frame.size.width
        let height = infoView.frame.origin.y + infoView.frame.size.height
        scrollView.contentSize = CGSize(width: width, height: height)
        
        overviewLabel.text = movie["overview"] as? String
        overviewLabel.sizeToFit()
        
        header.title = movie["title"] as? String
        
        let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: posterBaseUrl + posterPath)
            posterImageView.setImageWithURL(imageUrl!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
