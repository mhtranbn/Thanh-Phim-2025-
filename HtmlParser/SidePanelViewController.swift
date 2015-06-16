//
//  LeftViewController.swift
//  SlideOutNavigation
//
//  Created by James Frost on 03/08/2014.
//  Copyright (c) 2014 James Frost. All rights reserved.
//

import UIKit

//let delay = 0.1 * Double(NSEC_PER_SEC)
protocol SidePanelViewControllerDelegate {
    func movieTypeSelected(movieType : MovieType)
}

class SidePanelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, STADelegateProtocol {
 
    
    @IBOutlet weak var tableView: UITableView!
    var imageScr:UIImageView!
    var dem:Int = 0
    var startAppAdLoadShow: STAStartAppAd?

    var delegate: SidePanelViewControllerDelegate?
    var _data : NSArray!
    struct TableView {
        struct CellIdentifiers {
            static let MovieType = "MovieCell"
        }
    }
    
    override func loadView() {
        super.loadView()
        

        imageScr = UIImageView(image: UIImage(named: "screen.jpg"))
        self.view.addSubview(imageScr)
//        imageScr.image = UIImage(named: "screen.jpg")
        self.view.backgroundColor = UIColor.whiteColor()
        self.edgesForExtendedLayout = UIRectEdge.None
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        startAppAdLoadShow = STAStartAppAd()
        imageScr.setTranslatesAutoresizingMaskIntoConstraints(false)
        let views = ["view": self.view, "image": imageScr]
        //image cao 200 cach bottom 0
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0.0-[image(200)]", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views))
        // image cach leff,right 0
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0.0-[image]-30-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views))

        var dataFile : NSString = NSBundle.mainBundle().pathForResource("data", ofType: "plist")!
        _data =  NSArray(contentsOfFile: dataFile as String)

        
        var cellNib : UINib = UINib(nibName: "MovieTypeCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.MovieType)

        tableView.reloadData()

        

        
    }
    

    
   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (_data[1] as! NSArray).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.MovieType, forIndexPath: indexPath) as! MovieTypeCell
        cell.configureForMovieType((_data[1] as! NSArray)[indexPath.row] as! String)
        cell.backgroundColor = UIColor.grayColor()

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dem += 1
        if (dem == 5) {
            dem = 0
            loadAd()
        }
        var movieName = (_data[1] as! NSArray)[indexPath.row] as! String
        var movieLink = (_data[0] as! NSArray)[indexPath.row] as! String
        delegate?.movieTypeSelected(MovieType(name: movieName, type_url: movieLink))
    }
    
    func loadAd() {
        
      startAppAdLoadShow!.loadAd(STAAdType_Automatic, withDelegate: self)
    }
    
    func didLoadAd(ad: STAAbstractAd) {
        //        println("StartApp Ad had been loaded successfully")
        startAppAdLoadShow!.showAd()
    }
    
    // StartApp Ad failed to load
    func failedLoadAd(ad: STAAbstractAd, withError error: NSError) {
        //        println("StartApp Ad had failed to load")
    }
    
    // StartApp Ad is being displayed
    func didShowAd(ad: STAAbstractAd) {
        //        println("StartApp Ad is being displayed")
    }
    
    // StartApp Ad failed to display
    func failedShowAd(ad: STAAbstractAd, withError error: NSError) {
        //        println("StartApp Ad is failed to display")
    }
    
    // StartApp Ad is being displayed
    func didCloseAd(ad: STAAbstractAd) {
        //        println("StartApp Ad was closed")
    }
    
    // StartApp Ad is being displayed
    func didClickAd(ad: STAAbstractAd) {
        //        println("StartApp Ad was clicked")
    }


}
 