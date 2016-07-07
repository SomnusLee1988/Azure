//
//  SLAlertController.swift
//  Pods
//
//  Created by Somnus on 16/6/24.
//
//

import UIKit

public enum SLAlertAnimation : Int {
    
    case Fade
    case Top
    case None
}

public class SLAlertController: UIViewController {
    
    weak var rootViewController:UIViewController!
    var backgroundView:UIView!
    var alertView:UIView!
    var imageView:UIImageView!
    var image:UIImage!
    var tilteLabel:UILabel!
    var textView:UITextView!
    var actionView:UIView!
    var cancel_button:UIButton!
    var other_button:UIButton!
    public var alertTintColor:UIColor! = UIColor.whiteColor()
    public var alertTextColor:UIColor! = UIColor.whiteColor()
    var cancelAction:(()->Void)!
    var otherAction:(()->Void)!
    
    var delay:Double?
    var animationType:SLAlertAnimation?
    
    let padding:CGFloat = 20
    let alertWidth:CGFloat = 250
    let actionHeight:CGFloat = 60
    let buttonHeigth:CGFloat = 40

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor.RGBA(0, 0, 0, 0.5)
        self.backgroundView.backgroundColor = UIColor.clearColor()
        self.alertView.backgroundColor = alertTintColor
        self.alertView.layer.cornerRadius = 5.0
        self.alertView.layer.masksToBounds = true
        
        self.tilteLabel.textColor = alertTextColor
        
        if self.textView != nil {
            self.textView.textColor = alertTextColor
        }
        
        if self.cancel_button != nil {
            self.cancel_button.setTitleColor(alertTintColor, forState: .Normal)
            self.cancel_button.layer.borderColor = alertTintColor.CGColor
            self.cancel_button.layer.borderWidth = 1.0
            self.cancel_button.layer.cornerRadius = buttonHeigth / 2.0
            self.cancel_button.layer.masksToBounds = true
        }
        
        if self.other_button != nil {
            self.other_button.setTitleColor(alertTintColor, forState: .Normal)
            self.other_button.layer.borderColor = alertTintColor.CGColor
            self.other_button.layer.borderWidth = 1.0
            self.other_button.layer.cornerRadius = buttonHeigth / 2.0
            self.other_button.layer.masksToBounds = true
        }
        
        if self.actionView != nil {
            self.actionView.backgroundColor = UIColor.whiteColor()
        }
        

        
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public convenience init(title:String, message:String?=nil, image:UIImage?=nil, cancelButtonTitle:String?=nil, otherButtonTitle:String?=nil, delay:Double?=nil, withAnimation:SLAlertAnimation? = SLAlertAnimation.None) {
        self.init()
        self.backgroundView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = UIColor.clearColor()
        backgroundView.alpha = 0.5
        self.view.addSubview(backgroundView)
        
        self.alertView = UIView()
        self.view.addSubview(alertView)
        
        assert(!title.isEmpty, "alert title can not be empty!")
        
        self.tilteLabel = UILabel()
        tilteLabel.numberOfLines = 0
        tilteLabel.textAlignment = .Center
        tilteLabel.text = title
        self.alertView.addSubview(tilteLabel)
        
        if message != nil && !(message?.isEmpty)! {
            self.textView = UITextView()
            self.textView.editable = false
            self.textView.text = message
            self.textView.userInteractionEnabled = false
            self.textView.textAlignment = .Center
            self.textView.backgroundColor = UIColor.clearColor()
            self.alertView.addSubview(textView)
        }
        
        if image != nil {
            self.image = image
            self.imageView = UIImageView(image: image)
            self.alertView.addSubview(imageView)
        }
        
        if !(cancelButtonTitle == nil && otherButtonTitle == nil) {
            
            self.actionView = UIView()
            self.actionView.backgroundColor = UIColor.clearColor()
            self.alertView.addSubview(actionView)
            
            if cancelButtonTitle != nil{
                
                
                self.cancel_button = UIButton(type: .System)
                self.cancel_button.setTitle(cancelButtonTitle, forState: .Normal)
                self.cancel_button.addTarget(self, action: #selector(cancelButtonClicked), forControlEvents: .TouchUpInside)
                
                self.actionView.addSubview(cancel_button)
                
                
            }
            
            if otherButtonTitle != nil {
                
                self.other_button = UIButton(type: .System)
                self.other_button.setTitle(otherButtonTitle, forState: .Normal)
                self.other_button.addTarget(self, action: #selector(otherButtonClicked), forControlEvents: .TouchUpInside)
                self.actionView.addSubview(other_button)
                
            }
        }
        
        self.delay = delay
        self.animationType = withAnimation
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var y:CGFloat = 0.0
        
        let contentWdith = alertWidth - padding * 2
        
        if imageView != nil {
            self.imageView.frame.origin = CGPoint(x: (alertWidth - imageView.frame.width) / 2.0, y: padding)
            y += padding
            y += self.imageView.frame.height
        }
        
        y += padding
        
        let titlestr = tilteLabel.text
        let titleRect = titlestr!.boundingRectWithSize(CGSizeMake(contentWdith, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:tilteLabel.font], context: nil)
        self.tilteLabel.frame = CGRectMake(padding, y, contentWdith, ceil(titleRect.height))
        
        y += tilteLabel.frame.height
        y += padding
        
        if self.textView != nil {
            let textstr = textView.text
            let realsize = textView.sizeThatFits(CGSizeMake(contentWdith, CGFloat.max))
            let textRect = textstr!.boundingRectWithSize(CGSizeMake(contentWdith, realsize.height), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:textView.font!], context: nil)
            self.textView.frame = CGRectMake(padding, y, contentWdith, ceil(titleRect.height))
            y += tilteLabel.frame.height
            y += padding
        }
        
        if self.actionView != nil {
            self.actionView.frame = CGRectMake(0, y, alertWidth, actionHeight)
            y += actionHeight
            let buttonWidth = alertWidth / 3.0
            if self.cancel_button != nil && self.other_button != nil{
                self.cancel_button.frame = CGRectMake((alertWidth / 2.0 - buttonWidth) / 2.0, (actionHeight - buttonHeigth) / 2.0, buttonWidth, buttonHeigth)
                self.other_button.frame = CGRectMake(alertWidth / 2.0 + (alertWidth / 2.0 - buttonWidth) / 2.0, (actionHeight - buttonHeigth) / 2.0, buttonWidth, buttonHeigth)
                let seperator = UIView(frame: CGRectMake(alertWidth / 2.0, 0, 0.5, actionHeight))
                seperator.backgroundColor = self.alertTintColor
                self.actionView.addSubview(seperator)
            }
            else if self.cancel_button != nil && self.other_button == nil {
                self.cancel_button.frame = CGRectMake((alertWidth - buttonWidth) / 2.0, (actionHeight - buttonHeigth) / 2.0, buttonWidth, buttonHeigth)
            }
            else {
                self.other_button.frame = CGRectMake((alertWidth - buttonWidth) / 2.0, (actionHeight - buttonHeigth) / 2.0, buttonWidth, buttonHeigth)
            }
        }
        
        self.alertView.frame = CGRectMake((self.view.frame.width - alertWidth) / 2.0, (self.view.frame.height - y) / 2.0, alertWidth, y)
        
        
    }
    
    public func show(viewController:UIViewController, animated:Bool, completion:(() -> Void)?) {
        assert(NSThread.isMainThread(), "SLAlertController needs to be accessed on the main thread.")
        self.rootViewController = viewController
        
        self.view.alpha = 0
        self.definesPresentationContext = true
        self.modalPresentationStyle = .OverFullScreen
        
        switch self.animationType! {
        case .Fade:
            self.rootViewController.presentViewController(self, animated: false, completion: {
                
                UIView.animateWithDuration(0.3, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
                    self.view.alpha = 1.0
                    self.alertView.alpha = 1.0
                    }, completion: { finished in
                        if let d = self.delay {
                            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(d * Double(NSEC_PER_SEC)))
                            dispatch_after(delayTime, dispatch_get_main_queue()) {
                                self.hide(animated)
                            }
                        }
                })
                
            })
            
        case .Top:
            self.rootViewController.presentViewController(self, animated: false, completion: { 
                
                UIView.animateWithDuration(0.2, animations: { 
                    self.view.alpha = 1.0
                })
                
                self.alertView.center.x = self.view.center.x
                self.alertView.center.y = -500
                
                UIView.animateWithDuration(0.5, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
                    self.alertView.center = self.view.center
                    }, completion: { finished in
                        if let d = self.delay {
                            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(d * Double(NSEC_PER_SEC)))
                            dispatch_after(delayTime, dispatch_get_main_queue()) {
                                self.hide(true)
                            }
                        }
                })
            })
            
        case .None:
            self.view.alpha = 1.0
            
        }
    }
    
    func cancelButtonClicked() {
        self.hide(true)
    }
    
    func otherButtonClicked() {
        self.hide(true)
    }
    
    
    public func hide(animated:Bool) {
        assert(NSThread.isMainThread(), "SLAlertController needs to be accessed on the main thread.")
        if animated {
            switch self.animationType! {
            case .Fade:

                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                    self.view.alpha = 0.0
                    }, completion: { finished in
                        self.dismissViewControllerAnimated(false, completion: {
                            
                            if self.cancelAction != nil {
                                self.cancelAction()
                            }
                            
                            if self.otherAction != nil {
                                self.otherAction()
                            }
                        })
                })
                break
                
            case .Top:
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                    self.alertView.center.y = self.view.center.y + self.view.frame.height
                    }, completion: { finished in
                        UIView.animateWithDuration(0.1, animations: {
                            self.view.alpha = 0
                            }, completion: { finished in
                                self.dismissViewControllerAnimated(false, completion: {
                                    
                                    if self.cancelAction != nil {
                                        self.cancelAction()
                                    }
                                    
                                    if self.otherAction != nil {
                                        self.otherAction()
                                    }
                                })
                        })
                })
                break
                
            case .None:
                self.view.alpha = 0.0
                self.dismissViewControllerAnimated(false, completion: { 
                    if self.cancelAction != nil {
                        self.cancelAction()
                    }
                    
                    if self.otherAction != nil {
                        self.otherAction()
                    }
                })
                break
                
            }
        }
    }
    
    public func addCancelAction(action:()->Void) {
        self.cancelAction = action
    }
    
    public func addOtherAction(action: ()->Void) {
        self.otherAction = action
    }
    
    public func setTitleFont(font: UIFont) {
        self.tilteLabel.font = font
    }
    
    public func setTextFont(font: UIFont) {
        if self.textView != nil {
            self.textView.font = font
        }
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
