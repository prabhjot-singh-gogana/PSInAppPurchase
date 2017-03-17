//
//  AppDelegate.swift
//  PSInAppPurchase
//
//  Created by prabhjot singh on 11/23/16.
//  Copyright © 2016 Prabhjot Singh. All rights reserved.
//
// swiftlint:disable line_length
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        initializeThePSProducts()
        return true
    }
    func initializeThePSProducts() {
//        guard let products = PSProduct.multipleProductsThrough(productsMetaArray: [("The Stanker", "com.TheStanker.ProductTheStanker"),
//                                                         ("The Happy Stanker", "com.TheStanker.ProductTheHappyStanker"),
//                                                         ("The RainBow Stanker", "com.TheStanker.ProductTheRainbowStanker")]) else {
//                                                            return
//        }
        guard let products = PSProduct.multipleProductsThroughPlist() else {
            return
        }
        PSInAppPurchase.sharedInstance.request(forProducts: products) {(success) in
            PSInAppPurchase.sharedInstance.haveProducts = success
        }
    }

}
