//
//  DetailViewController.swift
//  Flicks
//
//  Created by Suraj Upreti on 2/13/17.
//  Copyright © 2017 Suraj Upreti. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var navigationText: UINavigationItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    var imageUrlString: String?
    var textDetails: String?
    var movieTitle: String?
    var releaseDate: String?
    var rating: Float?
    var index: Int?
    
    var movie: NSDictionary!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        detailsLabel.layer.cornerRadius = 7 //round edges of the label
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height + 10)
        
        navigationText.title = movieTitle
        titleLabel.text = movieTitle
        overviewLabel.text = textDetails
        overviewLabel.sizeToFit()
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        let date = dateFormatterGet.date(from: "\(releaseDate!)")
        releaseDateLabel.text = dateFormatterPrint.string(from: date!)
        
        ratingLabel.text = "\(rating!)"
        let imageUrlString = URL(string: self.imageUrlString!)
        if let imageUrlString = imageUrlString {
            posterImageView.setImageWith(imageUrlString)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
