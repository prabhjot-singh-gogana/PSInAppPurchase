//
//  PSInAppPurchase.swift
//  PSInAppPurchase
//
//  Created by prabhjot singh on 6/23/16.
//  Copyright © 2016 Prabhjot Singh. All rights reserved.
//
// swiftlint:disable line_length
import UIKit
import StoreKit
/**
 *  Product with SKProduct and some other properties
 */
struct PSProduct {
    var productName: String
    var productID: String
    var isOneTimePurchase: Bool = true
    var isPurchased: Bool = false
    fileprivate var product: SKProduct?
    init(name: String, productIdentifier: String) {
        self.productName = name
        self.productID = productIdentifier
        guard let purchased = PSInAppPurchase.getValueFromUserDefaultsForKey(productIdentifier), purchased == true else {
            self.isPurchased = false
            return
        }
        self.isPurchased = purchased
    }
    /**
     use to fetch the products through multiple meta tuple
     - parameter productsMetaArray: array of product info tuple
     - returns: returns the array pf product
     */
    static func multipleProductsThrough(productsMetaArray:[(name: String, productIdentifier: String)]) -> [PSProduct]? {
        var arrayOfProducts: [PSProduct]?
        for productsTuple in productsMetaArray {
            if arrayOfProducts == nil {
                arrayOfProducts = [PSProduct]()
            }
            arrayOfProducts?.append(PSProduct(name: productsTuple.name, productIdentifier: productsTuple.productIdentifier))
        }
        return arrayOfProducts
    }
    /**
     use to fetch the products through plist
     - returns: returns the array pf product
     */
    static func multipleProductsThroughPlist() -> [PSProduct]? {
        // Read plist from bundle and get Root Dictionary out of it
        guard let path = Bundle.main.path(forResource: "PurchaseList", ofType: "plist") else {
            return nil
        }
        guard let dictRoot = NSDictionary(contentsOfFile: path) else {
            return nil
        }
        var arrayOfProductMetaData: Array<(name: String, productIdentifier: String)>?
        for (key, value) in dictRoot {
            if arrayOfProductMetaData == nil {
                arrayOfProductMetaData = Array<(name: String, productIdentifier: String)>()
            }
            arrayOfProductMetaData?.append((name: key as! String, productIdentifier: value as! String))
        }
        guard let metaData = arrayOfProductMetaData else {
            return nil
        }
        return PSProduct.multipleProductsThrough(productsMetaArray: metaData)
    }
}

//MARK:- INAppPurchase Class
class PSInAppPurchase: NSObject {
    static let sharedInstance = PSInAppPurchase()
    var psProducts = [PSProduct]()
	fileprivate var productsRequest: SKProductsRequest?
	fileprivate var completionHandler: ((Bool) -> Void)?
    fileprivate var buyProductHandler: ((Bool) -> Void)?
    var haveProducts = false
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    /**
     use to request the products from In-App Purchase or Apple
     - parameter psProducts: model of PSProduct with identifier
     - parameter handler:    handles the boolean
     */
    internal func request(forProducts psProducts: [PSProduct], withHandler handler: @escaping ((Bool) -> Void)) {
        self.psProducts = psProducts
        self.completionHandler = handler
        let arrayOfIdentifier = self.psProducts.map { (value: PSProduct) -> String in
            return value.productID
        }
        if arrayOfIdentifier.count == 0 {
            self.completionHandler!(false)
            return
        }
        let setOfProducts = Set(arrayOfIdentifier)
		if SKPaymentQueue.canMakePayments() {
			productsRequest = SKProductsRequest(productIdentifiers:setOfProducts )
			productsRequest?.delegate = self
			productsRequest?.start()
        } else {
            self.completionHandler!(false)
        }
	}
    /**
     method use to buy the product through PSProduct object
     - parameter product: model of PSProduct with identifier
     - parameter handler: handle the boolean
     */
	internal func buyProduct(productIdentifier productID: String, handler: @escaping ((Bool) -> Void)) {
        buyProductHandler = handler
        guard let buyProduct = self.productThroughID(productID) else {
            buyProductHandler!(false)
            return
        }
        if buyProduct.product == nil {
            buyProductHandler!(false)
            return
        }
        setProductToSharedProducts(product: buyProduct)
        if buyProduct.isPurchased == true {
            buyProductHandler!(true)
            return
        }
		let payment = SKPayment(product: buyProduct.product!)
		SKPaymentQueue.default().add(payment)
	}
    internal func setProductToSharedProducts(product: PSProduct?) {
        guard let buyProduct = product else {return}
        for (index, value) in self.psProducts.enumerated() {
            if value.productID == buyProduct.productID {
                self.psProducts[index] = buyProduct
            }
        }
    }
    /**
     method use to restore the transaction
     */
    internal func restoreCompletedTransactions() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

// MARK: Other Methods
    /**
     fecth the details from SKProduct and convert it into one string
     - parameter product: model of SkProduct
     - returns: returns the string
     */
    internal func localizedPriceForProduct(_ product: SKProduct) -> String {
        let priceFormatter = NumberFormatter()
        priceFormatter.formatterBehavior = NumberFormatter.Behavior.behavior10_4
        priceFormatter.numberStyle = NumberFormatter.Style.currency
        priceFormatter.locale = product.priceLocale
        return priceFormatter.string(from: product.price)!
    }
    internal func productThroughID(_ productID: String) -> PSProduct? {
        if self.haveProducts && self.psProducts.count > 0 {
            var product = self.psProducts.filter{($0.productID == productID)}.first
            guard let purchased = PSInAppPurchase.getValueFromUserDefaultsForKey(productID) else {
                product!.isPurchased = false
                return product
            }
            product!.isPurchased = purchased
            return product
        }
        return nil
    }
// MARK: Save in UseDefault
//  Get value from user defaults
    class func getValueFromUserDefaultsForKey(_ keyName: String!) -> Bool? {
        return UserDefaults.standard.bool(forKey: keyName)
    }
// Set value to user defaults
    class func setValueToUserDefaultsForKey(_ keyName: String!, value: Bool!) {
        if  keyName.characters.count == 0 || value == nil {
            return
        }
        UserDefaults.standard.set(value, forKey: keyName) //setObject(value, forKey: keyName)
        UserDefaults.standard.synchronize()
    }
}



//MARK:- SKProducts Delegates

extension PSInAppPurchase: SKProductsRequestDelegate {
     func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products")
        self.productsRequest = nil
        let skproducts = response.products
    // Filtered the array
        for product in skproducts {
            self.psProducts = psProducts.flatMap({ ( psProduct) -> PSProduct? in
                var newPSProduct = psProduct
                if product.productIdentifier == newPSProduct.productID {
                    newPSProduct.product = product
                    return newPSProduct
                }
                return psProduct
            })
        }
        self.completionHandler?(true)
        completionHandler = nil
    }
}

//MARK:- SKRequests Delegates

extension PSInAppPurchase: SKRequestDelegate {
    func requestDidFinish(_ request: SKRequest) {
    }
    func request(_ request: SKRequest, didFailWithError error: Error) {
        productsRequest = nil
        self.completionHandler?(false)
        self.completionHandler = nil
    }

}

//MARK:-  SKPaymentTransaction Delegates

extension PSInAppPurchase: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                completeTransaction(transaction)
                break
            case .failed:
                failedTransaction(transaction)
                break
            case .restored:
                restoreTransaction(transaction)
                break
            case .purchasing:
                print("Purchasing!")
            default:
                break
            }
        }
    }
    fileprivate func completeTransaction(_ transaction: SKPaymentTransaction) {
        PSInAppPurchase.setValueToUserDefaultsForKey(transaction.payment.productIdentifier, value: true)
        if buyProductHandler != nil {
            buyProductHandler!(true)
        }
    }
    fileprivate func restoreTransaction(_ transaction: SKPaymentTransaction) {
        print("Restore transaction")
        PSInAppPurchase.setValueToUserDefaultsForKey(transaction.payment.productIdentifier, value: true)
        if buyProductHandler != nil {
            buyProductHandler!(true)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    fileprivate func failedTransaction(_ transaction: SKPaymentTransaction) {
        print("Failed transaction")
        if transaction.transactionState != .failed {
            print("Transaction error: \(transaction.error!.localizedDescription)")
        }
        if buyProductHandler != nil {
            buyProductHandler!(false)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
