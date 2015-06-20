//
//  ViewController.swift
//  HtmlParser
//
//  Created by dohai2105 on 2/11/15.
//  Copyright (c) 2015 dohai2105. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import AVFoundation


@objc
protocol CenterViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func collapseSidePanels()
}



class ListMovieController: UIViewController,NSURLSessionDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate,SidePanelViewControllerDelegate, STADelegateProtocol{
    var session: NSURLSession!
    var movieList: [Movie] = [Movie]()
    var currentPage: Int = 1
    var isLoading = false
    let movieSingleton  = MovieSingleton.sharedInstance
    let CELLID = "MovieCell"
    var num_column = 3
    var startAppAdLoadShow: STAStartAppAd?
    @IBOutlet weak var qdwdw: UILabel!
    let SPACE = 20
    var _flowLayuot : UICollectionViewFlowLayout!
    var isSearch = false
    var canClickMovie :Bool?
    var dem:Int = 0
    var flagSearch:Bool = false
    var userNSdefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var movieTypeTG: String = "http://mmovie.hdviet.com/hoat-hinh.x11.p"
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var delegate: CenterViewControllerDelegate?
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = true

        startAppAdLoadShow = STAStartAppAd()
        navigationController!.navigationBar.barTintColor = UIColor(red: 0.3, green:0.8, blue: 1, alpha: 1)
        self.searchBar.barTintColor = UIColor(red: 0.3, green:0.8, blue: 1, alpha: 1)
        self.searchBar.layer.borderColor = UIColor(red: 0.3, green:0.8, blue: 1, alpha: 1).CGColor
        self.searchBar.layer.borderWidth = 1
        self.view.addSubview(searchBar)

        self.searchBar.delegate = self
        
//       collectionView.scrollEnabled = false
        initMovieGrid()
        getDataHTML()
        setupGestureRecognizer()
        setupGestureRecognizer2()
        
     }
    
    func shuffle<C: MutableCollectionType where C.Index == Int>(var list: C) -> C {
        let counts = count(list)
        for i in 0..<(counts - 1) {
            let j = Int(arc4random_uniform(UInt32(counts - i))) + i
            swap(&list[i], &list[j])
        }
        return list
    }
    
    func getDataHTML() {
        self.canClickMovie = false
        dem += 1
        if (dem == 10) {
            dem = 0
            loadAd()
        }

        //check net work
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (status:AFNetworkReachabilityStatus) -> Void in
            switch status.hashValue{
            case AFNetworkReachabilityStatus.NotReachable.hashValue:
                NSLog("Not reachable")
                self.qdwdw.text = NSString(UTF8String: "") as? String
                self.qdwdw.text = NSString(UTF8String: "Hãy kết nối lại wifi or cellular networks.") as? String
                                        self.qdwdw.textAlignment = NSTextAlignment.Center
                                        self.qdwdw.font = UIFont.systemFontOfSize(15)
                self.movieList = []
                self.collectionView.reloadData()
                
            case AFNetworkReachabilityStatus.ReachableViaWiFi.hashValue , AFNetworkReachabilityStatus.ReachableViaWWAN.hashValue :
                self.initDialog()
                self.isLoading = true
                self.qdwdw.text = NSString(UTF8String: "") as? String
                var datastring: String!
                let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
                configuration.timeoutIntervalForRequest = 15.0
                /* Now create our session which will allow us to create the tasks */
                self.session = NSURLSession(configuration: configuration, delegate: self,
                    delegateQueue: nil)
                var url: NSURL!
                var timkiem = "http://mmovie.hdviet.com/tim-kiem-theo-loai.html?key="
                if !self.isSearch{
                    url = NSURL(string: "\(self.movieSingleton.currentMovieType)\(self.currentPage).html")
                    self.qdwdw.text = NSString(UTF8String: "") as? String
                }else {
                    if (self.flagSearch == false) {
                        timkiem += self.searchBar.text + "&&page=\(self.currentPage)"
                        url = NSURL(string: timkiem.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
                    } else {
                        url = NSURL(string: "\(self.movieSingleton.currentMovieType)\(self.currentPage).html")
                        self.qdwdw.text = NSString(UTF8String: "") as? String
                        self.flagSearch = false
                    }
                    
    
                }
                if (url == nil) {
                }
                else {
                    let task = self.session.dataTaskWithURL(url!, completionHandler: {[weak self] (data: NSData!,
                        response: NSURLResponse!, error: NSError!) in
//                        NSLog("&&&&&&&\(error)")
//                        if ((!error) != nil) {
//                            
//                        }
//                        var error: NSError?
                        /* We got our data here */
                        datastring = NSString(data:data, encoding:NSUTF8StringEncoding)! as String
//                         NSLog("%%%%%%%%%\(datastring)")
//                        NSLog("%%%%%%%%%\(datastring)")
                        var parser = NDHpple(HTMLData: datastring!)
                        var query0 = "//div[@class='abc'] /a"
                        var query = "//div[@class='movie-ribbon']//a"
//                        NSLog("********\(parser.searchWithXPathQuery(query0))")
                       
                        if (parser.searchWithXPathQuery(query0) == nil && (self!.isSearch == false || parser.searchWithXPathQuery(query) == nil)){
                            self!.qdwdw.text = NSString(UTF8String: "Hãy kết nối wifi or cellular networks khác.") as? String
                            self!.qdwdw.textAlignment = NSTextAlignment.Center
                            self!.qdwdw.font = UIFont.systemFontOfSize(15)

                            self!.indicator.stopAnimating()
                            
                        }

                        
                        else {
                            
                            
                            if (parser.searchWithXPathQuery(query) == nil) {
                                if (parser.searchWithXPathQuery(query) == nil && self!.isSearch == true && self?.searchBar.text != nil && parser.searchWithXPathQuery(query0) != nil){
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self!.qdwdw.text = NSString(UTF8String: "Chưa có phim bạn tìm kiếm.") as? String
                                        self!.qdwdw.textAlignment = NSTextAlignment.Center
                                        self!.qdwdw.font = UIFont.systemFontOfSize(15)
//                                        NSLog("++++++=\(self!.qdwdw.text)")
                                    }
                                    
                                }
                                if (parser.searchWithXPathQuery(query) == nil && self!.isSearch == true && self?.searchBar.text == nil && parser.searchWithXPathQuery(query0) != nil) {
                                    self!.qdwdw.text = NSString(UTF8String: "") as? String
                                }
//                                if (parser.searchWithXPathQuery(query0) == nil && parser.searchWithXPathQuery(query) == nil){
//                                    self!.qdwdw.text = NSString(UTF8String: "Hãy kết nối wifi or cellular networks khác.") as? String
//                                    self!.qdwdw.textAlignment = NSTextAlignment.Center
//                                    self!.qdwdw.font = UIFont.systemFontOfSize(15)
//                                }
                                
                            }
                                
                            else {
                                self!.qdwdw.text = NSString(UTF8String: "") as? String
                                var result:Array = parser.searchWithXPathQuery(query)!
                                var tmpMovieList = [Movie]()
                                for node in result {
                                    var img_url: String = node.firstChild!.attributes["src"] as! String
                                    img_url = img_url.stringByReplacingOccurrencesOfString("100x149", withString: "214x321", options: NSStringCompareOptions.LiteralSearch, range: nil)
                                    var movie_url: String  = node.attributes["href"] as! String
                                    var movie: Movie = Movie(img_url: img_url, movie_url: movie_url)
                                    tmpMovieList.append(movie)
                                }
                                if (tmpMovieList.count == 0){
                                    
                                }
                                tmpMovieList = self!.shuffle(tmpMovieList)
                                dispatch_async(dispatch_get_main_queue()) {
                                    if error == nil {
                                        for movie in tmpMovieList {
                                            self?.movieList.append(movie)
                                            
                                        }
                                        self?.collectionView.reloadData()
                                        self?.isLoading = false
                                        self?.indicator.stopAnimating()
                                        
                                    }
                                }
                            }
                            
                            
                        }

                        dispatch_async(dispatch_get_main_queue()) {
                            if error == nil {
                                self?.collectionView.reloadData()
                                self?.isLoading = false
                                self?.indicator.stopAnimating()
                            }
                        }
                      
                        self!.session.finishTasksAndInvalidate() })
                    task.resume()
                    // unlock man hinh
                    self.canClickMovie = true

                }

            default:
                NSLog("Unknown status")
                self.indicator.stopAnimating()
            }}

        
    }
    func initMovieGrid(){
        
        var cellNib : UINib = UINib(nibName: "MovieCell", bundle: nil)
        self.collectionView?.registerNib(cellNib, forCellWithReuseIdentifier: CELLID)
        
        var colWidth = self.computeColWidth(num_column)
        
        _flowLayuot = UICollectionViewFlowLayout()
        
        _flowLayuot.itemSize = CGSize(width: CGFloat(colWidth) - 1, height: CGFloat(colWidth * 1.5))
        
        _flowLayuot.scrollDirection = UICollectionViewScrollDirection.Vertical
        
        _flowLayuot.minimumInteritemSpacing = CGFloat(SPACE/2)
        
        _flowLayuot.sectionInset = UIEdgeInsetsMake(1, 0, 1, 0)
        
        _flowLayuot.headerReferenceSize = CGSizeMake(1, 1)
        
        self.collectionView?.collectionViewLayout = _flowLayuot
        
        self.collectionView.dataSource = self
        
        self.collectionView.delegate = self
    }
    
//    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        NSLog("The default search bar cancel button was tapped.")
//        initMovieGrid()
//        
//        searchBar.resignFirstResponder()
//    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        NSLog("=========\(searchText)")
//        self.collectionView.dataSource = self
//        self.collectionView.delegate = self
//        self.collectionView.reloadData()
        if (searchText == "") {
            flagSearch = true
            movieSingleton.currentMovieType = movieTypeTG
            NSLog(")))))))))(\(movieTypeTG))")
            self.isSearch = true
            currentPage = 1
            movieList.removeAll(keepCapacity: true)
            getDataHTML()
            searchBar.resignFirstResponder()
        }
        
        
    }
    
    func computeColWidth(numberColum : Int) -> Float {
        return Float((Float(self.view.bounds.width)  - Float(2*SPACE) ))/3.0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return movieList.count
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(CELLID, forIndexPath: indexPath) as! UICollectionViewCell
        var movieCell : MovieCell = cell as! MovieCell

        if cell.isKindOfClass(MovieCell) {
            var movieCell : MovieCell = cell as! MovieCell
            var imgURL = self.movieList[indexPath.row].img_url
            movieCell.movieCellImg.setImageWithURL(NSURL(string: imgURL), placeholderImage: UIImage(named:imgURL))
            
        }
        movieCell.layer.borderColor = UIColor.grayColor().CGColor
        movieCell.layer.borderWidth = 0.5
        // Check load more
        if indexPath.row > movieList.count - 2 && movieList.count > 20*currentPage {
            currentPage++
            self.getDataHTML()
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        if (canClickMovie == true) {
            dem += 1

            if (dem == 10) {
                dem = 0
                loadAd()
            }
            var id = (self.movieList[indexPath.row].movie_url as String).stringByReplacingOccurrencesOfString("http://mmovie.hdviet.com/hdviet.", withString: "", options:NSStringCompareOptions.LiteralSearch , range: nil).stringByReplacingOccurrencesOfString(".html", withString: "", options:NSStringCompareOptions.LiteralSearch , range: nil)
            var token = (self.movieList[indexPath.row].img_url as String).stringByReplacingOccurrencesOfString("http://t.hdviet.com/thumbs/214x321/", withString: "", options:NSStringCompareOptions.LiteralSearch , range: nil).stringByReplacingOccurrencesOfString(".jpg", withString: "", options:NSStringCompareOptions.LiteralSearch , range: nil)
            
            var decompileUrl = movieSingleton.decompileMovieHdViet(id, token: token, ep: "")
            
            self.getMovieURL(decompileUrl)
            canClickMovie = false
        }
        if (canClickMovie == false) {

            
        }

    }
    
    @IBAction func leftMenuClick(sender: UIBarButtonItem) {
        self.isLoading = false
        self.indicator?.stopAnimating()
        self.isSearch = false
        delegate?.toggleLeftPanel!()
        
        
    }
    
    func movieTypeSelected(movieType : MovieType){
        self.isSearch = false
        currentPage = 1
        movieSingleton.currentMovieType = movieType.type_url
        movieTypeTG = movieType.type_url
        NSLog(")rrrrrrrrrr(\(movieTypeTG))")
        movieList.removeAll(keepCapacity: true)
        getDataHTML()
        self.navigationItem.title = movieType.name
        delegate?.collapseSidePanels?()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        self.isSearch = true
        currentPage = 1
        movieList.removeAll(keepCapacity: true)
        getDataHTML()
        searchBar.resignFirstResponder()
    }
    
    var indicator:UIActivityIndicatorView!
    func initDialog(){
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        indicator.frame = CGRectMake(0.0, 0.0, 60, 60);
        indicator.center = self.view.center;
        indicator.layer.cornerRadius = 8;
        indicator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        indicator.layer.zPosition = 1
        self.view.addSubview(indicator)
        
        indicator.bringSubviewToFront(self.view)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        indicator.startAnimating()
    }
    
    func initVideoPlayer(url: String,subURL: String) {
        
        let videoURL = NSURL(string: url)
        
        var filePathStr = NSBundle.mainBundle().pathForResource("example", ofType: "mp4")

        
        // Subtitles file
        var subtitlesPathStr = NSBundle.mainBundle().pathForResource("example", ofType: "srt")
        
        // Create MoviePlayer
        var player = MyMoviePlayerVC(contentURL: videoURL)
        
        if (subURL != ""){
            var afHttpRequestManager = AFHTTPRequestOperationManager()
            afHttpRequestManager.responseSerializer = AFHTTPResponseSerializer()
            
            afHttpRequestManager.GET( subURL ,
                parameters: nil,
                success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                var content = NSString(data: responseObject as! NSData, encoding: NSUTF8StringEncoding)
                    if content == nil {
                        content = NSString(data: responseObject as! NSData, encoding: NSUTF16StringEncoding)
                    }
                    if content == nil {
                        content = NSString(data: responseObject as! NSData, encoding: NSUTF32StringEncoding)
                    }

                    player.moviePlayer.openWithSRTString(content as! String, completion: { (Bool) -> Void in
                        player.moviePlayer.showSubtitles()
                        self.presentMoviePlayerViewControllerAnimated(player)
                    }, failure: nil)
                },
                failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                    println("Error: " + error.localizedDescription)
            })
            canClickMovie = true
        }else {
            player.moviePlayer.play()
            self.presentMoviePlayerViewControllerAnimated(player)
            canClickMovie = true
        }
        
    }
    
    
    
    func getMovieURL(movieURl:String) {
        
            var afHttpRequestManager = AFHTTPRequestOperationManager()
        afHttpRequestManager.GET( "https://api.hdviet.com/movie/play?\(movieURl)",
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                let responseDict = responseObject as! Dictionary<String, AnyObject>
                var movieObject = responseDict["r"] as! Dictionary<String, AnyObject>
                var movieFinal = movieObject["LinkPlay"] as! String
                var subUrl: String = ""
                if let subUrlContainer = movieObject["SubtitleExt"] as! Dictionary<String, AnyObject>? {
                    if let  vietSubContainer = subUrlContainer["VIE"] as! Dictionary<String, AnyObject>? {
                        subUrl =  vietSubContainer ["Source"] as! String
                        println(subUrl)
                    }
                }
                
                movieFinal = movieFinal.stringByReplacingOccurrencesOfString("480", withString: "1920", options:NSStringCompareOptions.LiteralSearch , range: nil)
                self.initVideoPlayer(movieFinal,subURL: subUrl)
                
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                println("Error: " + error.localizedDescription)
        })
    }
    
    func checkNet() {
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (status:AFNetworkReachabilityStatus) -> Void in
            switch status.hashValue{
            case AFNetworkReachabilityStatus.NotReachable.hashValue:
                NSLog("Not reachable")
            case AFNetworkReachabilityStatus.ReachableViaWiFi.hashValue , AFNetworkReachabilityStatus.ReachableViaWWAN.hashValue :
                NSLog("Reachable")
            default:
                NSLog("Unknown status")
            }}
    }
    
    func setupGestureRecognizer() {
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        dismissKeyboardTap.cancelsTouchesInView = false
        
        self.navigationController?.navigationBar.addGestureRecognizer(dismissKeyboardTap)
    }
    func setupGestureRecognizer2() {
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        dismissKeyboardTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(dismissKeyboardTap)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    

    func loadAd() {
        
        // Set some preferences
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

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }


}



