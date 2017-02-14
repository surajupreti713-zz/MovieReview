//
//  InfiniteScrollActivityView.swift
//  Flicks
//
//  Created by Suraj Upreti on 2/13/17.
//  Copyright © 2017 Suraj Upreti. All rights reserved.
//

import UIKit

class InfiniteScrollActivityView: UIView {

    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    
    static let defaultHeight:CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.color = UIColor(red: 0.4, green: 1.0, blue: 0.5, alpha: 1.0)
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.isHidden = true
    }
    
    func startAnimating() {
        self.isHidden = false
        self.activityIndicatorView.startAnimating()
    }

}
