//
//  ViewController.swift
//  PocketQuest
//
//  Created by Flavio Lici on 7/18/16.
//  Copyright © 2016 Flavio Lici. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var team: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pickATeam(sender: UIButton) {
        if sender.tag == 1 {
            team = "Instinct"
        } else if sender.tag == 2 {
            team = "Mystic"
        } else if sender.tag == 3 {
            team = "Valor"
        }
        
        setFunction()
        self.performSegueWithIdentifier("goToGame", sender: self)
    }
    
    func setFunction() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(team, forKey: "team")
        defaults.setInteger(0, forKey: "Points")
    }


}

