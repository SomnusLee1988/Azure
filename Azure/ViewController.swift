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

let URL_SUFFIX = "(format=m3u8-aapl)"
private var azureContext = 0

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var liveCollectionView: UICollectionView!
    @IBOutlet var videoCollectionView: UICollectionView!
    
    @IBOutlet var segmentBar: UIView!
    @IBOutlet var liveButton: UIButton!
    @IBOutlet var videoButton: UIButton!
    @IBOutlet var contentWidthConstraint: NSLayoutConstraint!
    
    var videoArray:[AnyObject] = []
    var liveArray:[AnyObject] = []
    
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
        
        self.queryVideoData()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        contentWidthConstraint.constant = view.frame.width * 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func queryVideoData() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
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
                    let videoURL = NSURL(string: hlsUrl)
                    let player = AVPlayer(URL: videoURL!)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.presentViewController(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
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
                    let videoURL = NSURL(string: hlsUrl)
                    let player = AVPlayer(URL: videoURL!)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.presentViewController(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                })
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetRatio = scrollView.contentOffset.x / self.view.frame.width
        var frame = self.segmentBar.frame
        frame.origin.x = self.view.frame.width / 4.0 - segmentBar.frame.width / 2.0 + offsetRatio * (self.view.frame.width / 2.0)
        segmentBar.frame = frame
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 {
            selectedSegmentIndex = 0
        }
        else if scrollView.contentOffset.x == self.view.frame.width {
            selectedSegmentIndex = 1
        }
    }
    
    // MARK: -
    func segmentIndexChanged() {
        if selectedSegmentIndex == 0 {
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: { 
                var frame = self.segmentBar.frame
                frame.origin.x = self.view.frame.width / 4.0 - frame.width / 2.0
                self.segmentBar.frame = frame
                }, completion: { (finished) in
                    self.liveButton.setTitleColor(UIColor.RGB(47, 160, 251), forState: .Normal)
                    self.videoButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            })
            
        }
        else if selectedSegmentIndex == 1 {
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: {
                var frame = self.segmentBar.frame
                frame.origin.x = self.view.frame.width * 3.0 / 4.0 - frame.width / 2.0
                self.segmentBar.frame = frame
                }, completion: { (finished) in
                    self.liveButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
                    self.videoButton.setTitleColor(UIColor.RGB(47, 160, 251), forState: .Normal)
            })
        }
    }

    @IBAction func liveButtonClicked(sender: AnyObject) {
        selectedSegmentIndex = 0
    }
    
    @IBAction func videoButtonClicked(sender: AnyObject) {
        selectedSegmentIndex = 1
    }
}

