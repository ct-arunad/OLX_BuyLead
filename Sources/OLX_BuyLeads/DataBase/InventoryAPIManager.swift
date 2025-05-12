//
//  InventoryAPIManager.swift
//  InventorySwift
//
//  Created by Vikram on 10/08/24.
//

import UIKit
import CoreData

class InventoryAPIManager: NSObject {
    

        var m_ModelManager: InventoryModelManager = InventoryModelManager()


    var deleteObjectIndex: Int = 0
    var m_Makes = [AnyHashable: Any]()
    var m_Models = [AnyHashable: Any]()
    var m_Variants = [AnyHashable: Any]()
    var m_stocks = [AnyHashable: Any]()

    // MARK: - Singleton
    static let sharedInstance: InventoryAPIManager = {
        let instance = InventoryAPIManager()
        return instance
    }()
    
    override init() {
        super.init()
    //    if self != nil {
            self.loadData()
     //   }
    }

    
    func loadData() {
        m_ModelManager = InventoryModelManager.sharedInstance
        m_ModelManager.loadFromDB()
        
     //   self.loadMakes()
    //    self.loadModels()
       // self.loadVariants()
        self.loadStocks()
    }
    
    
    
    
    //MARK: - AAMakes

//    func loadMakes(){
//        m_Makes =  [AnyHashable:Any](minimumCapacity:(m_ModelManager.makes.count))
//        for obj:Makes in m_ModelManager.makes {
//            m_Makes[obj.makeId] = obj
//        }
//    }
//    
    func addStocks(ads:Ads?){
        if ads != nil {
            m_stocks[(ads?.adId)!] = ads
            InventoryModelManager.sharedInstance.saveContext()
        }else {
            InventoryModelManager.sharedInstance.saveContext()
        }
    }
    func fetchAllMakeData(context: NSManagedObjectContext) -> [Makes] {
        let request: NSFetchRequest<Makes> = Makes.fetchRequest()
        request.relationshipKeyPathsForPrefetching = ["models", "models.variants"]
        request.predicate = NSPredicate(format: "name == %@", "Maruti Suzuki")
        do {
            let makes = try context.fetch(request)
            return makes
        } catch {
            print("❌ Failed to fetch Makes:", error)
            return []
        }
    }
    func fetchStatesMakeData(context: NSManagedObjectContext) -> [States] {
        let request: NSFetchRequest<States> = States.fetchRequest()
        request.relationshipKeyPathsForPrefetching = ["cites"]
      //  request.predicate = NSPredicate(format: "name == %@", "Maruti Suzuki")
        do {
            let states = try context.fetch(request)
            return states
        } catch {
            print("❌ Failed to fetch Makes:", error)
            return []
        }
    }
    func fetchCitiesMakeData(context: NSManagedObjectContext,predicate : String) -> [States] {
        let request: NSFetchRequest<States> = States.fetchRequest()
        request.relationshipKeyPathsForPrefetching = ["cites"]
        request.predicate = NSPredicate(format: "name == %@", predicate)
        do {
            let states = try context.fetch(request)
            return states
        } catch {
            print("❌ Failed to fetch Makes:", error)
            return []
        }
    }
    
    func fetchleadStatusData(context: NSManagedObjectContext) -> [LeadStatus] {
        let request: NSFetchRequest<LeadStatus> = LeadStatus.fetchRequest()
        request.relationshipKeyPathsForPrefetching = ["subleads"]
      //  request.predicate = NSPredicate(format: "name == %@", "Maruti Suzuki")
        do {
            let leadstatus = try context.fetch(request)
            return leadstatus
        } catch {
            print("❌ Failed to fetch Makes:", error)
            return []
        }
    }
    
    func fetchsubleadsData(context: NSManagedObjectContext,predicate : String) -> [LeadStatus] {
        let request: NSFetchRequest<LeadStatus> = LeadStatus.fetchRequest()
        request.relationshipKeyPathsForPrefetching = ["cites"]
        request.predicate = NSPredicate(format: "name == %@", predicate)
        do {
            let subleads = try context.fetch(request)
            return subleads
        } catch {
            print("❌ Failed to fetch Makes:", error)
            return []
        }
    }
    
    func loadStocks(){
        m_stocks =  [AnyHashable:Any](minimumCapacity:(m_ModelManager.stocks.count))
        for obj:Ads in m_ModelManager.stocks {
            m_stocks[obj.adId] = obj
        }
    }
    func  getStocks()-> AnyObject{
        
        var returnArray:[Ads] = [Ads]()
        let stocksArray:[Ads] = (m_stocks as NSDictionary).allValues as! [Ads]
        var returnStockArry:[String] = [String]()
        for obj:Ads in stocksArray {
                returnArray.append(obj)
            returnStockArry.append(obj.name ?? "")
        }
//        let orderedSet = NSOrderedSet(array: returnArray)
//        let arrayWithoutDuplicates: [Any] = orderedSet.array
//        let sortedArray = arrayWithoutDuplicates.sorted { ($0 as AnyObject).localizedCaseInsensitiveCompare($1 ) == ComparisonResult.orderedAscending }
        return returnArray as AnyObject
    }

    
    func getsubleads(leadstate : String) -> AnyObject{
        var returnCitiesArry:[String] = [String]()
        let states = fetchsubleadsData(context: InventoryModelManager.sharedInstance.context,predicate: leadstate)
        for state in states {
            for city in state.subleads ?? [] {
                let city = city as! SubLeads
              //  print("  city: \(city.name ?? "")")
                returnCitiesArry.append(city.name ?? "")
            }
        }
        let orderedSet = NSOrderedSet(array: returnCitiesArry)
        let arrayWithoutDuplicates: [Any] = orderedSet.array
        let sortedArray = arrayWithoutDuplicates.sorted { ($0 as AnyObject).localizedCaseInsensitiveCompare($1 as! String) == ComparisonResult.orderedAscending }
        return sortedArray as AnyObject
    }
    
    func getleadStatus() -> AnyObject{
        var returnLeadsArray:[String] = [String]()
        let leadmainstatus = fetchleadStatusData(context: InventoryModelManager.sharedInstance.context)
        for leadstatus in leadmainstatus {
         //   print("state: \(state.name ?? "")")
            returnLeadsArray.append(leadstatus.name ?? "")
        }
        let orderedSet = NSOrderedSet(array: returnLeadsArray)
        let arrayWithoutDuplicates: [Any] = orderedSet.array
        let sortedArray = arrayWithoutDuplicates.sorted { ($0 as AnyObject).localizedCaseInsensitiveCompare($1 as! String) == ComparisonResult.orderedAscending }
        return sortedArray as AnyObject
    }
    
    
    func getstates() -> AnyObject{
        var returnStatesArray:[String] = [String]()
        let states = fetchStatesMakeData(context: InventoryModelManager.sharedInstance.context)
        for state in states {
         //   print("state: \(state.name ?? "")")
            returnStatesArray.append(state.name ?? "")
        }
        let orderedSet = NSOrderedSet(array: returnStatesArray)
        let arrayWithoutDuplicates: [Any] = orderedSet.array
        let sortedArray = arrayWithoutDuplicates.sorted { ($0 as AnyObject).localizedCaseInsensitiveCompare($1 as! String) == ComparisonResult.orderedAscending }
        return sortedArray as AnyObject
    }
    func getCities(state : String) -> AnyObject{
        var returnCitiesArry:[String] = [String]()
        let states = fetchCitiesMakeData(context: InventoryModelManager.sharedInstance.context,predicate: state)
        for state in states {
            for city in state.cities ?? [] {
                let city = city as! Cities
              //  print("  city: \(city.name ?? "")")
                returnCitiesArry.append(city.name ?? "")
            }
        }
        let orderedSet = NSOrderedSet(array: returnCitiesArry)
        let arrayWithoutDuplicates: [Any] = orderedSet.array
        let sortedArray = arrayWithoutDuplicates.sorted { ($0 as AnyObject).localizedCaseInsensitiveCompare($1 as! String) == ComparisonResult.orderedAscending }
        return sortedArray as AnyObject
    }
    func getVariants()-> AnyObject{
        var returnvarientsArry:[String] = [String]()
        let makes = fetchAllMakeData(context: InventoryModelManager.sharedInstance.context)
        for make in makes {
         //   print("Make: \(make.name ?? "")")
            for model in make.models ?? [] {
                let model = model as! Models
                for variant in model.varients ?? [] {
                    let variant = variant as! Variants
                    returnvarientsArry.append(variant.name ?? "")
                }
            }
        }
        let orderedSet = NSOrderedSet(array: returnvarientsArry)
        let arrayWithoutDuplicates: [Any] = orderedSet.array
        let sortedArray = arrayWithoutDuplicates.sorted { ($0 as AnyObject).localizedCaseInsensitiveCompare($1 as! String) == ComparisonResult.orderedAscending }
        return sortedArray as AnyObject
    }
    func  getMakes()-> AnyObject{
        var returnMakesArry:[String] = [String]()
        let makes = fetchAllMakeData(context: InventoryModelManager.sharedInstance.context)
        for make in makes {
           // print("Make: \(make.name ?? "")")
            returnMakesArry.append(make.name ?? "")
        }
        let orderedSet = NSOrderedSet(array: returnMakesArry)
        let arrayWithoutDuplicates: [Any] = orderedSet.array
        let sortedArray = arrayWithoutDuplicates.sorted { ($0 as AnyObject).localizedCaseInsensitiveCompare($1 as! String) == ComparisonResult.orderedAscending }
        return sortedArray as AnyObject
    }
    func  getModels()-> AnyObject{
        
        var returnModelsArry:[String] = [String]()
        let makes = fetchAllMakeData(context: InventoryModelManager.sharedInstance.context)
        for make in makes {
          //  print("Make: \(make.name ?? "")")
            for model in make.models ?? [] {
                let model = model as! Models
            //    print("  Model: \(model.name ?? "")")
                returnModelsArry.append(model.name ?? "")
            }
        }
        let orderedSet = NSOrderedSet(array: returnModelsArry)
        let arrayWithoutDuplicates: [Any] = orderedSet.array
        let sortedArray = arrayWithoutDuplicates.sorted { ($0 as AnyObject).localizedCaseInsensitiveCompare($1 as! String) == ComparisonResult.orderedAscending }
        return sortedArray as AnyObject
    }
    //MARK:- AAModels

//    func loadModels(){
//        m_Models =  [AnyHashable:Any](minimumCapacity:(m_ModelManager.models.count))
//        for obj:Models in m_ModelManager.models {
//                m_Models[obj.modelId] = obj
//        }
//    }
//    
//    func addModels(models:Models?){
//        if models != nil {
//            m_Models[(models?.modelId)!] = models
//            InventoryModelManager.sharedInstance.saveContext()
//        }else {
//            InventoryModelManager.sharedInstance.saveContext()
//        }
//    }
    func  getModels_old()-> AnyObject{
        
        let fetchRequest: NSFetchRequest<Models> = Models.fetchRequest()
            do {
                let models = try InventoryModelManager.sharedInstance.context.fetch(fetchRequest)
                print(models)
            } catch {
                print("❌ Failed to fetch makes:", error)
                print([])
            }
        
    //    let modelsArray:[Models] = (m_Models as NSDictionary).allValues as! [Models]
        let returnModelsArry:[String] = [String]()
        let orderedSet = NSOrderedSet(array: returnModelsArry)
        let arrayWithoutDuplicates: [Any] = orderedSet.array
        let sortedArray = arrayWithoutDuplicates.sorted { ($0 as AnyObject).localizedCaseInsensitiveCompare($1 as! String) == ComparisonResult.orderedAscending }
        return sortedArray as AnyObject
    }

    //MARK: - AAVariants
    
    func loadVariants(){
        m_Variants =  [AnyHashable:Any](minimumCapacity:(m_ModelManager.variants.count))
        for obj:Variants in m_ModelManager.variants {
                m_Variants[obj.variantId] = obj
        }
    }
    
    func addVariants(variants:Variants?){
        if variants != nil {
            m_Variants[(variants?.variantId)!] = variants
            InventoryModelManager.sharedInstance.saveContext()
        }else {
            InventoryModelManager.sharedInstance.saveContext()
        }
    }
 

    
    
    //MARK: - Remove Sync Data From DB
      
         
      
      func removeDataFromDBAtIndex(index:Int){
      
      deleteObjectIndex = index
          
          let entitiesArray: [Any] = ["Makes","Models","Variants"]

          if deleteObjectIndex < entitiesArray.count {
          
            if entitiesArray[deleteObjectIndex] as! String == "Makes" {
              InventoryModelManager.sharedInstance.makes.removeAll()
              m_Makes.removeAll()
          }
          else if entitiesArray[deleteObjectIndex] as! String == "Models" {
              InventoryModelManager.sharedInstance.models.removeAll()
              m_Models.removeAll()
          }
          else if entitiesArray[deleteObjectIndex] as! String == "Variants" {
              InventoryModelManager.sharedInstance.variants.removeAll()
              m_Variants.removeAll()
          }
              
              let success:Bool = InventoryModelManager.sharedInstance.clearEntity(entity: entitiesArray[deleteObjectIndex]  as! String)
              if success {
                  deleteObjectIndex += 1
                  self.removeDataFromDBAtIndex(index: deleteObjectIndex)
              }
          }
          
      }
    
}
