//
//  WatchMovieViewController.swift
//  HtmlParser
//
//  Created by DoHai on 3/22/15.
//  Copyright (c) 2015 dohai2105. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class WatchMovieViewController: UIViewController {

    var movieURl: String = ""
    var player : AVPlayer? = nil
    var playerLayer : AVPlayerLayer? = nil
    var asset : AVAsset? = nil
    var playerItem: AVPlayerItem? = nil
    
    @IBOutlet weak var backButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
//        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
//        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
    }
    override func viewDidAppear(animated: Bool) {
        backButton.layer.zPosition = 1
        initDialog()
        getMovieURL()
    }
    
    func initVideoPlayer(url: String) {

        let videoURL = NSURL(string: url)
        
        asset = AVAsset.assetWithURL(videoURL) as? AVAsset
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: self.playerItem)
        player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)

        playerLayer = AVPlayerLayer(player: self.player)
        playerLayer!.frame = view.frame
        view.layer.addSublayer(self.playerLayer)
        
        player!.play()

    }
    
    func getMovieURL() {
        var afHttpRequestManager = AFHTTPRequestOperationManager()
        afHttpRequestManager.GET( "https://api.hdviet.com/movie/play?\(movieURl)",
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                let responseDict = responseObject as! Dictionary<String, AnyObject>
                var movieObject = responseDict["r"] as! Dictionary<String, AnyObject>
                var movieFinal = movieObject["LinkPlay"] as! String
                movieFinal = movieFinal.stringByReplacingOccurrencesOfString("480", withString: "1920", options:NSStringCompareOptions.LiteralSearch , range: nil)
                self.initVideoPlayer(movieFinal)
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                println("Error: " + error.localizedDescription)
        })
    }
    var indicator:UIActivityIndicatorView!
    func initDialog(){
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        indicator.center = self.view.center;
        self.view.addSubview(indicator)
        indicator.bringSubviewToFront(self.view)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        indicator.startAnimating()
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
//        println((object as AVPlayer).status)
        if keyPath == "status" && object as! NSObject == player! {
            if player?.status == AVPlayerStatus.ReadyToPlay {
                self.indicator.stopAnimating()
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)

            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        player?.removeObserver(self, forKeyPath: "status")
    }

    override func shouldAutorotate() -> Bool {
        return true
    }
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }
    
    @IBAction func backClick(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
