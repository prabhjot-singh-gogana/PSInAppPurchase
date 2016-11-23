//
//  ViewController.swift
//  PSInAppPurchase
//
//  Created by prabhjot singh on 6/23/16.
//  Copyright © 2016 Prabhjot Singh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func toPurchaseAProduct(_ sender: AnyObject) {
        PSInAppPurchase.sharedInstance.buyProduct(psProduct: PSInAppPurchase.sharedInstance.psProducts[0]) { (success) in
            if success == true {
                print("Purchased! Enjoy")
            }
        }
    }

    @IBAction func restoreStanker(_ sender: AnyObject) {
        print(PSInAppPurchase.sharedInstance.psProducts[0].isPurchased)
        
        PSInAppPurchase.sharedInstance.restoreCompletedTransactions()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
