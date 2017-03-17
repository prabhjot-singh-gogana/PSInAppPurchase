//
//  ViewController.swift
//  PSInAppPurchase
//
//  Created by prabhjot singh on 6/23/16.
//  Copyright © 2016 Prabhjot Singh. All rights reserved.
//
// swiftlint:disable line_length
import UIKit

enum IdentifierOfProducts {
    case TheStanker
    case TheHappyStanker
    case TheRainbowStaker
    var identity: String {
        switch self {
        case .TheStanker:
            return "com.TheStanker.ProductTheStanker"
        case .TheHappyStanker:
            return "com.TheStanker.ProductTheHappyStanker"
        case .TheRainbowStaker:
            return "com.TheStanker.ProductTheRainbowStanker"
        }
    }
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func toPurchaseAProduct(_ sender: AnyObject) {
        PSInAppPurchase.sharedInstance.buyProduct(productIdentifier: IdentifierOfProducts.TheHappyStanker.identity) { (success) in
            if success == true {
                print("Purchased! Enjoy")
            }
        }
    }
    @IBAction func restoreStanker(_ sender: AnyObject) {
        print(PSInAppPurchase.sharedInstance.productThroughID(IdentifierOfProducts.TheHappyStanker.identity) ?? "")
        PSInAppPurchase.sharedInstance.restoreCompletedTransactions()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
