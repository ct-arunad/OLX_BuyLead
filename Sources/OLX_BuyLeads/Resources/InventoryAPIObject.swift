//
//  InventoryAPIObject.swift
//  InventorySwift
//
//  Created by Vikram on 10/08/24.
//

import UIKit
import CoreData

class InventoryAPIObject: NSObject {
    

        
    //    override init() {
    //        // init is called by subclasses, therefore we need to implement it
    //        return super.init()
    //    }
        
        // Abstract method - cannot be called
        func modelObj() -> NSManagedObject? {
            doesNotRecognizeSelector(#function)
            return nil
        }
        
        // Abstract method - cannot be called
        func sync(_ updateData: [AnyHashable: Any]) {
            doesNotRecognizeSelector(#function)
        }
        
        // Abstract method - cannot be called
        func createNew(_ objectID: NSNumber) {
            doesNotRecognizeSelector(#function)
        }
        
}
