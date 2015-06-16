//
//  MyMoviePlayerVC.swift
//  HtmlParser
//
//  Created by DoHai on 3/30/15.
//  Copyright (c) 2015 dohai2105. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
class MyMoviePlayerVC: MPMoviePlayerViewController {

    override func shouldAutorotate() -> Bool {
        return UIDevice.currentDevice().orientation.rawValue != UIInterfaceOrientation.Portrait.rawValue
    }

    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }
}
