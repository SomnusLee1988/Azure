//
//  ViewController.swift
//  Azure
//
//  Created by Somnus on 16/7/5.
//  Copyright © 2016年 Somnus. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import AVFoundation
import AVKit
import Alamofire
import MJRefresh
import SLAlertController

let URL_SUFFIX = "(format=m3u8-aapl)"
private var azureContext = 0

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var liveCollectionView: UICollectionView!
    @IBOutlet var videoCollectionView: UICollectionView!
    
    @IBOutlet var segmentBar: UIView!
    @IBOutlet var liveButton: UIButton!
    @IBOutlet var videoButton: UIButton!
    @IBOutlet var liveBtnBackgroundView: UIView!
    @IBOutlet var videoBtnBackgroundView: UIView!
    @IBOutlet var contentWidthConstraint: NSLayoutConstraint!
    @IBOutlet var segmentBarLeadingConstraint: NSLayoutConstraint!
    
    var videoArray:[AnyObject] = []
    var liveArray:[AnyObject] = []
    
    var segmentBarConstraints = [NSLayoutConstraint]()
    
    var selectedSegmentIndex = -1 {
        didSet {
            self.segmentIndexChanged()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.addObserver(self, forKeyPath: "selectedSegmentIndex", options: .New, context: &azureContext)
        selectedSegmentIndex = 0
        
        self.liveCollectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: { 
            self.queryVideoData()
        })
        
        self.videoCollectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.queryVideoData()
        })
        
        self.queryVideoData()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        contentWidthConstraint.constant = view.frame.width * 2
        
        NSLayoutConstraint.deactivateConstraints([segmentBarLeadingConstraint])
        NSLayoutConstraint.deactivateConstraints(segmentBarConstraints)
        segmentBarConstraints.removeAll()
        
        if selectedSegmentIndex == 0 {
            segmentBarConstraints.append(NSLayoutConstraint(item: segmentBar, attribute: .CenterX, relatedBy: .Equal, toItem: liveBtnBackgroundView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            self.scrollView.contentOffset.x = 0
        }
        else {
            segmentBarConstraints.append(NSLayoutConstraint(item: segmentBar, attribute: .CenterX, relatedBy: .Equal, toItem: videoBtnBackgroundView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            self.scrollView.contentOffset.x = self.view.frame.width
        }
        
        NSLayoutConstraint.activateConstraints(segmentBarConstraints)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.videoCollectionView.collectionViewLayout.invalidateLayout()
        self.liveCollectionView.collectionViewLayout.invalidateLayout()
        
//        if selectedSegmentIndex == 0 {
//            self.scrollView.contentOffset.x = 0
//        }
//        else {
//            self.scrollView.contentOffset.x = size.width
//        }
        
    }
    
    func queryVideoData() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        videoArray.removeAll()
        liveArray.removeAll()
        Alamofire.request(.GET, "http://epush.huaweiapi.com/content").validate().responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching remote videos: \(response.result.error)")
                return
            }
            
            guard let value = response.result.value as? [AnyObject] else {
                print("Malformed data received from queryVideoData service")
                return
            }
            
            for dict in value {
                if let mode = dict["mode"] as? String where mode == "0" {
                    self.videoArray.append(dict)
                }
                else if let mode = dict["mode"] as? String where mode == "1" {
                    self.liveArray.append(dict)
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.liveCollectionView.mj_header.endRefreshing()
                self.videoCollectionView.mj_header.endRefreshing()
                self.liveCollectionView.reloadData()
                self.videoCollectionView.reloadData()
            })
        }
        
        
    }

    //MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == liveCollectionView
        {
            return liveArray.count
        }
        else if collectionView == videoCollectionView
        {
            return videoArray.count
        }
        
        return 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView == liveCollectionView
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellID1", forIndexPath: indexPath) as! AzureCollectionViewCell
            
            let data = liveArray[indexPath.row]
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                if let imageUrl = data["poster"] as? String
                {
                    if let imageData = NSData(contentsOfURL: NSURL(string: imageUrl)!)
                    {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.imageView.image = UIImage(data: imageData)
                        })
                    }
                }
                
            })
            
            if let name = data["name"] as? String {
                cell.titleLabel.text = name
            }
            
            
            if let desc = data["desc"] as? String {
                cell.descriptionLabel.text = desc
            }
            
            if let hlsUrl = data["hlsUrl"] as? String {
                cell.playButton.addHandler({
                    let videoURL = NSURL(string: hlsUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
                    let player = AVPlayer(URL: videoURL!)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.presentViewController(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                })
            }
            else {
                cell.playButton.addHandler({
                    let alert = SLAlertController(title: "Something wrong may happen with this video", message: nil, image: nil, cancelButtonTitle: "OK", otherButtonTitle: nil, delay: nil, withAnimation: SLAlertAnimation.Fade)
                    alert.alertTintColor = UIColor.RGB(255, 58, 47)
                    alert.show(self, animated: true, completion: nil)
                })
            }
            
            
            return cell
        }
        else if collectionView == videoCollectionView
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellID2", forIndexPath: indexPath) as! AzureCollectionViewCell

            let data = videoArray[indexPath.row]
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                if let imageUrl = data["poster"] as? String
                {
                    if let imageData = NSData(contentsOfURL: NSURL(string: imageUrl)!)
                    {
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.imageView.image = UIImage(data: imageData)
                        })
                        
                    }
                }
                
            })
            
            
            if let name = data["name"] as? String {
                cell.titleLabel.text = name
            }
            
            
            if let desc = data["desc"] as? String {
                cell.descriptionLabel.text = desc
            }
            
            if let hlsUrl = data["hlsUrl"] as? String {
                cell.playButton.addHandler({
                    let videoURL = NSURL(string: hlsUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
                    let player = AVPlayer(URL: videoURL!)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.presentViewController(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                })
            }
            else {
            
                cell.playButton.addHandler({
                    let alert = SLAlertController(title: "Something wrong may happen with this video", message: nil, image: nil, cancelButtonTitle: "OK", otherButtonTitle: nil, delay: nil, withAnimation: SLAlertAnimation.Fade)
                    alert.alertTintColor = UIColor.RGB(255, 58, 47)
                    alert.show(self, animated: true, completion: nil)
                })
                
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let offsetRatio = scrollView.contentOffset.x / self.view.frame.width
            var frame = self.segmentBar.frame
            frame.origin.x = self.view.frame.width / 4.0 - segmentBar.frame.width / 2.0 + offsetRatio * (self.view.frame.width / 2.0)
            segmentBar.frame = frame
        }
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            if self.scrollView.contentOffset.x == 0 {
                selectedSegmentIndex = 0
            }
            else if self.scrollView.contentOffset.x == self.view.frame.width {
                selectedSegmentIndex = 1
            }
        }
        
    }
    
    // MARK: -
    func segmentIndexChanged() {
        if selectedSegmentIndex == 0 {
            
            self.liveButton.setTitleColor(UIColor.RGB(47, 160, 251), forState: .Normal)
            self.videoButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            
        }
        else if selectedSegmentIndex == 1 {
            
            self.liveButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            self.videoButton.setTitleColor(UIColor.RGB(47, 160, 251), forState: .Normal)
        }
    }

    @IBAction func liveButtonClicked(sender: AnyObject) {
        selectedSegmentIndex = 0
        self.scrollView.scrollRectToVisible(self.liveCollectionView.frame, animated: true)
    }
    
    @IBAction func videoButtonClicked(sender: AnyObject) {
        selectedSegmentIndex = 1
        self.scrollView.scrollRectToVisible(self.videoCollectionView.frame, animated: true)
    }
}

