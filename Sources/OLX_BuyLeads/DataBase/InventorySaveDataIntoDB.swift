//
//  InventorySaveDataIntoDB.swift
//  InventorySwift
//
//  Created by Vikram on 10/08/24.
//

import UIKit
import CoreData

class InventorySaveDataIntoDB: NSObject {

    var background = false;
    static let sharedInstance: InventorySaveDataIntoDB = {
        let instance = InventorySaveDataIntoDB()
        return instance
    }()
    func saveleadsandsubleadsIntoDB(response: Any) {
        
        guard let responseDic = response as? [String: Any] else { return }
        guard let statesArray = responseDic["buyleadstatus"]! as? [[String: Any]] else { return }
        let context = CoreDataStack.shared.persistentContainer.viewContext
        for (_, stateDict) in statesArray.enumerated() {
            let statuses = NSEntityDescription.insertNewObject(forEntityName: "LeadStatus", into: InventoryModelManager.sharedInstance.context) as! LeadStatus
            statuses.name = stateDict["name"] as? String
            for sublead in stateDict["substatus"] as! NSArray{
                let SubLeads = NSEntityDescription.insertNewObject(forEntityName: "SubLeads", into: InventoryModelManager.sharedInstance.context) as! SubLeads
                let sublead = sublead as! [String:Any]
                SubLeads.name = (sublead["name"] as! String)
                statuses.addToSubleads(SubLeads)
            }
        }
        do {
            try context.save()
            print("status and substatus saved successfully to Core Data.")
            
        } catch {
            print("Failed to save: \(error)")
        }
    }
    
    
        func saveStockTitles(_ response: Any?) {
            guard let makesArray = response as? [[String: Any]] else { return }
            let context = CoreDataStack.shared.persistentContainer.viewContext
            let backgroundContext2 = InventoryModelManager.sharedInstance.ManagedObjectContext()
            backgroundContext2.performAndWait {
                for makeDict in makesArray {
                    let stocks = NSEntityDescription.insertNewObject(forEntityName: "Ads", into: InventoryModelManager.sharedInstance.context) as! Ads
                    stocks.name = makeDict["title"] as? String
                    stocks.adId = makeDict["adId"] as? String
                    InventoryAPIManager.sharedInstance.addStocks(ads: stocks)
                }
            }
                try? backgroundContext2.save()
                do {
                    try context.save()
                } catch {
                    print("Failed to save: \(error)")
                }
    
        }
    
  
    func saveStatesandcitiesIntoDB(response: Any) {
        
        guard let responseDic = response as? [String: Any] else { return }
        guard let statesArray = responseDic["data"]! as? [[String: Any]] else { return }
        let context = CoreDataStack.shared.persistentContainer.viewContext
        for (_, stateDict) in statesArray.enumerated() {
            let states = NSEntityDescription.insertNewObject(forEntityName: "States", into: InventoryModelManager.sharedInstance.context) as! States
            states.name = stateDict["state"] as? String
            for city in stateDict["cities"] as! NSArray{
                let cities = NSEntityDescription.insertNewObject(forEntityName: "Cities", into: InventoryModelManager.sharedInstance.context) as! Cities
                let city = city as! String
                cities.name = city
                states.addToCities(cities)
            }
        }
        do {
            try context.save()
            print("states and cities saved successfully to Core Data.")
            
        } catch {
            print("Failed to save: \(error)")
        }
    }
    // MARK: - SaveMakesModelsAndVariants
    func saveMakesModelsAndVariantsIntoDB(response: Any) {
        guard let responseDic = response as? [String: Any] else { return }
        self.saveCarDataToCoreData(from: responseDic["models"]!, context: InventoryModelManager.sharedInstance.context)
    }
    func saveCarDataToCoreData(from response: Any, context: NSManagedObjectContext) {
        
        guard let modelsArray = response as? [[String: Any]] else { return }
        let context = CoreDataStack.shared.persistentContainer.viewContext
        for (_, modelDict) in modelsArray.enumerated() {
            let make = NSEntityDescription.insertNewObject(forEntityName: "Makes", into: InventoryModelManager.sharedInstance.context) as! Makes
            make.name = modelDict["make"] as? String
            for modelData in modelDict["models"] as! NSArray{
                let model = NSEntityDescription.insertNewObject(forEntityName: "Models", into: InventoryModelManager.sharedInstance.context) as! Models
             //   print(modelData)
                let modeldic = modelData as! [String: Any]
                model.name = (modeldic["model"] as! String)
                make.addToModels(model)
                for variantName in modeldic["variants"]  as! NSArray{
                    let variant = NSEntityDescription.insertNewObject(forEntityName: "Variants", into: InventoryModelManager.sharedInstance.context) as! Variants
                    variant.name = (variantName as! String)
                    model.addToVarients(variant)
                }
            }
        }
        do {
            try context.save()
            print("makes, models and varients saved successfully to Core Data.")
            
        } catch {
            print("Failed to save: \(error)")
        }
    }


}
