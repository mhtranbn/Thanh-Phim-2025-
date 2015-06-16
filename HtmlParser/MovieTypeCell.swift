//
//  MovieTypeCell.swift
//  HtmlParser
//
//  Created by DoHai on 3/22/15.
//  Copyright (c) 2015 dohai2105. All rights reserved.
//

import UIKit


class MovieTypeCell: UITableViewCell {
    
    @IBOutlet weak var imageNameLabel: UILabel!
    func configureForMovieType(name: String) {
        imageNameLabel.text = name
        imageNameLabel.textColor = UIColor.whiteColor()
    }
}