//
//  LocalChatViewController.swift
//  PocketQuest
//
//  Created by Flavio Lici on 7/19/16.
//  Copyright © 2016 Flavio Lici. All rights reserved.
//

import UIKit
import CoreLocation
import PubNub
import Foundation

var chan = ""

class LocalChatViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, PNObjectEventListener, UITextFieldDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var messageTextField: UITextField!
    
    var locationManager: CLLocationManager!
    
    var kPreferredTextFieldToKeyboardOffset: CGFloat = 70.0
    var keyboardFrame: CGRect = CGRect.null
    var keyboardIsShowing: Bool = false
    
    @IBOutlet weak var messageTable: UITableView!
    
    
    func chatMessageToDictionary(message: chatMessage) -> [String : NSString] {
        return [
            "text": NSString(string: message.text),
            "image": NSString(string: message.image)
        ]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessageArray.count
    }
    
    
    var chatMessageArray:[chatMessage] = []
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.messageTextField.delegate = self
        messageTable.dataSource = self
        
        self.messageTable.separatorStyle = UITableViewCellSeparatorStyle.None
        
        updateTableview()
        
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func updateHistory(){
        
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        
        appDel.client?.historyForChannel(chan, start: nil, end: nil, includeTimeToken: true, withCompletion: { (result, status) -> Void in
            self.chatMessageArray = self.parseJson(result!.data.messages)
            self.updateTableview()
            
        })
    }
 
    
    func keyboardWillShow(notification: NSNotification)
    {
        self.keyboardIsShowing = true
        
        if let info = notification.userInfo {
            self.keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            self.arrangeViewOffsetFromKeyboard()
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        self.keyboardIsShowing = false
        
        self.returnViewToInitialFrame()
    }
    
    func arrangeViewOffsetFromKeyboard()
    {
        let theApp: UIApplication = UIApplication.sharedApplication()
        let windowView: UIView? = theApp.delegate!.window!
        
        let textFieldLowerPoint: CGPoint = CGPointMake(self.messageTextField!.frame.origin.x, self.messageTextField!.frame.origin.y + self.messageTextField!.frame.size.height)
        
        let convertedTextFieldLowerPoint: CGPoint = self.view.convertPoint(textFieldLowerPoint, toView: windowView)
        
        let targetTextFieldLowerPoint: CGPoint = CGPointMake(self.messageTextField!.frame.origin.x, self.keyboardFrame.origin.y - kPreferredTextFieldToKeyboardOffset)
        
        let targetPointOffset: CGFloat = targetTextFieldLowerPoint.y - convertedTextFieldLowerPoint.y
        let adjustedViewFrameCenter: CGPoint = CGPointMake(self.view.center.x, self.view.center.y + targetPointOffset)
        
        UIView.animateWithDuration(0.2, animations:  {
            self.view.center = adjustedViewFrameCenter
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if (self.messageTextField != nil)
        {
            self.messageTextField?.resignFirstResponder()
            self.messageTextField = nil
        }
    }
    
    @IBAction func textFieldDidReturn(textField: UITextField!)
    {
        textField.resignFirstResponder()
        self.messageTextField = nil
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        self.messageTextField = textField
        
        if(self.keyboardIsShowing)
        {
            self.arrangeViewOffsetFromKeyboard()
        }
    }
    
    func returnViewToInitialFrame()
    {
        let initialViewRect: CGRect = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)
        
        if (!CGRectEqualToRect(initialViewRect, self.view.frame))
        {
            UIView.animateWithDuration(0.2, animations: {
                self.view.frame = initialViewRect
            });
        }
    }
    
    func initPubNub(){
        print("Init Pubnub")
        
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        
        appDel.client?.unsubscribeFromChannels([chan], withPresence: true) // If pubnub exists, unsubscribe
        appDel.client?.removeListener(self)
        
        var config = PNConfiguration( publishKey: "pub-c-b2fdfd68-ad63-41c9-9063-8dda1938e734", subscribeKey: "sub-c-f20463b8-5e51-11e6-bca9-0619f8945a4f")
        config.uuid = "Pokemaster"
        config.presenceHeartbeatValue = 30
        config.presenceHeartbeatInterval = 10
        
        appDel.client = PubNub.clientWithConfiguration(config)
        
        appDel.client?.addListener(self)
        
        self.joinChannel(chan)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = chan
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        for subview in self.view.subviews
        {
            if (subview.isKindOfClass(UITextField))
            {
                let textField = subview as! UITextField
                textField.addTarget(self, action: "textFieldDidReturn:", forControlEvents: UIControlEvents.EditingDidEndOnExit)
                
                textField.addTarget(self, action: "textFieldDidBeginEditing:", forControlEvents: UIControlEvents.EditingDidBegin)
                
            }
        }
    
        
    }
    
    deinit {
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        
    
        
        appDel.client?.removeListener(self)
    }
    
    func joinChannel(channel: String){
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        appDel.client?.subscribeToChannels([channel], withPresence: true)
        
        let deviceToken: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("deviceToken")
        print("**********deviceToken is **** \(deviceToken)")
        
      
        
        appDel.client?.addPushNotificationsOnChannels(["push"], withDevicePushToken: deviceToken as! NSData, andCompletion: nil)
        
       
        updateHistory()
    }
    
    func parseJson(anyObj:AnyObject) -> Array<chatMessage>{
        
        var list:Array<chatMessage> = []
        
        if  anyObj is Array<AnyObject> {
            
            for jsonMsg in anyObj as! Array<AnyObject>{
                let json = jsonMsg["message"] as! NSDictionary
                let imageJson  =  (json["image"]  as AnyObject? as? String) ?? ""
                let textJson  =  (json["text"]  as AnyObject? as? String) ?? ""

                
                list.append(chatMessage(image: textJson, text: imageJson))
            }
            self.messageTable.reloadData()
            
            
        }
        
        return list
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        let location = locations.last! as CLLocation
        
        var geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error in
            
            if error == nil && placemarks!.count > 0 {
                for placemark in placemarks! {
                    var state = placemark.administrativeArea!
                    print(state)
                    chan = state
                }
                self.locationManager.stopUpdatingLocation()
            }
        })
        
        
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        
        var message = messageTextField.text
        if(message == "") {return}
        else{
            var pubChat = chatMessage(image: "Articuno", text: message!)
            
            var newDict = chatMessageToDictionary(pubChat)
            
            appDel.client?.publish(newDict, toChannel: chan, compressed: true, withCompletion: nil)
            
            messageTextField.text = nil
            updateTableview()
        }
    }
    
    var randomNumber = Int(arc4random_uniform(10))
    
    func generateRandomImage(randomNum: Int) -> String {
        if randomNum == 1 {
            return "Articuno"
        } else if randomNum == 2 {
            return "Moltres"
        } else if randomNum == 3 {
            return "Mew"
        } else if randomNum == 4 {
            return "MewTwo"
        } else if randomNum == 5 {
            return "Zapdos"
        } else if randomNum == 6 {
            return "Ditto"
        } else if randomNum == 7 {
            return "Charizard"
        } else if randomNum == 8 {
            return "Blastoise"
        } else if randomNum == 9 {
            return "Venusaur"
        } else {
            return "Pikachu"
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        messageTable.allowsSelection = false
        
        let cell: ChatCellTableViewCell = self.messageTable.dequeueReusableCellWithIdentifier("cell") as! ChatCellTableViewCell
            
            
            
            cell.message.textColor = UIColor.blackColor()
        
            cell.message.text = chatMessageArray[indexPath.row].text as String
        
            
            let imageName = "Articuno"
            let newImage = UIImage(named: imageName)
            cell.imageView?.hidden = false
            cell.imageView!.image = newImage


        
        return cell
    }

    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    func updateTableview(){
        self.messageTable.reloadData()
        
        if self.messageTable.contentSize.height > self.messageTable.frame.size.height {
            messageTable.scrollToRowAtIndexPath(NSIndexPath(forRow: chatMessageArray.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {
        print("******didReceiveMessage*****")
        print(message.data)
        print("*******UUID from message IS \(message.uuid)")
        
        var stringData  = message.data.message as! NSDictionary
        var stringText  = stringData["text"] as! String
        var stringImage = stringData["image"] as! String
      
        
        var newMessage = chatMessage(image: stringImage, text: stringText)
        
        chatMessageArray.append(newMessage)
        updateChat()
        
    }
    
    func client(client: PubNub!, didReceivePresenceEvent event: PNPresenceEventResult!) {
        print("******didReceivePresenceEvent*****")
        print(event.data)
        print("*******UUID from presence IS \(event.uuid)")
        
        
        var occ = event.data.presence.occupancy.stringValue
        
        updateChat()
        
        
    }
    
    func updateChat(){
        messageTable.reloadData()
        
        let numberOfSections = messageTable.numberOfSections
        let numberOfRows = messageTable.numberOfRowsInSection(numberOfSections-1)
        
        if numberOfRows > 0 {
            let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
            messageTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        
    }

}
