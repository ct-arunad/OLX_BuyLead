//
//  InventoryModelManager.swift
//  InventorySwift
//
//  Created by Vikram on 10/08/24.
//

import UIKit
import CoreData

class InventoryModelManager: NSObject {
    

    var makes = [Makes]()
    var models = [Models]()
    var variants = [Variants]()
    var stocks = [Ads]()

    
    var m_modelDic = [AnyHashable: Any]()
    var modelDic = [AnyHashable: Any]()

//    var managedObjectContext: NSManagedObjectContext!
//    private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    
     let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }


// MARK: - Singleton
    static let sharedInstance: InventoryModelManager = {
        let instance = InventoryModelManager()
        return instance
    }()

//    override init() {
//        super.init()
//        if self != nil {
//            m_modelDic = [AnyHashable: Any]()
//            modelDic=m_modelDic
//        }
//    }
    
    func copy(withZone zone: NSZone) -> Any {
        
        return self
    }

    // MARK: - ManagedObjectContext
    
    func ManagedObjectContext() -> NSManagedObjectContext {
        return context
    }
//    
//    func currentContext() -> NSManagedObjectContext {
//         // let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
////        let inventory = Inventory()
////        let context = inventory.persistentContainer.viewContext
//        
//         let context = CoreDataStack.shared.persistentContainer.viewContext
////        else {
////            fatalError("Failed to initialize NSManagedObjectContext")
////        }
//        return context
//    }

    
//    func saveContext() {
//            do {
//                try self.currentContext().save()
//            }  catch let error as NSError
//            {
//                NSLog("Unresolved error \(error), \(error.userInfo)")
//            }
//    }

     func saveContext() {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Failed to save context: \(error)")
                }
            }
        }
    
    func loadFromDB(){
    
        makes = self.loadEntityFromDB(entityName: "Makes") as! [Makes]
        models = self.loadEntityFromDB(entityName: "Models") as! [Models]
        variants = self.loadEntityFromDB(entityName: "Variants") as! [Variants]
        stocks = self.loadEntityFromDB(entityName: "Ads") as! [Ads]

    }
    
    func loadEntityFromDB(entityName: String) -> AnyObject {
        return loadEntity(fromDB: entityName, withPredicateFormat: nil)
    }
    
    func loadEntity(fromDB entityName: String, withPredicateFormat predicateFormat: NSPredicate?) -> AnyObject {
        var fetchResults: [Any]?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        var entity: NSEntityDescription?
        entity = NSEntityDescription.entity(forEntityName: entityName, in:context)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.entity = entity
        
        if predicateFormat != nil {
            fetchRequest.predicate = predicateFormat
        }
        fetchResults = try! context.fetch(fetchRequest)
        if fetchResults == nil {
            print("Error fetching \(entityName)")
        }
        else {
            print("\(entityName) fetching succeeded")
        }
        return fetchResults as AnyObject
    }
    
    func clearEntity(entity: String) -> Bool{
    
        let fetchAllObjects = NSFetchRequest<NSFetchRequestResult>()
        fetchAllObjects.entity = NSEntityDescription.entity(forEntityName: entity, in: context)
        fetchAllObjects.includesPropertyValues = false  //only fetch the managedObjectID
        let allObjects: [NSManagedObject] = try! context.fetch(fetchAllObjects) as! [NSManagedObject]

        for  object: NSManagedObject in allObjects {
            context.delete(object)
        }
        let saveError: Error? = nil
        
        return saveError == nil
    }
    
    
    //MARK:-  Add/Remove Activity

    func addStocks(objects: Ads){
        stocks.append(objects)
    }
    func removeStocks(objects: Ads) {
        stocks.remove(at: stocks.firstIndex(of: objects)!)
    }

    
    func addMakes(objects: Makes){
        makes.append(objects)
    }
    func removeAAMakes(objects: Makes) {
        makes.remove(at: makes.firstIndex(of: objects)!)
    }

    func addModels(objects: Models){
        models.append(objects)
    }
    func removeAAModels(objects: Models) {
        models.remove(at: models.firstIndex(of: objects)!)
    }

    func addAAVariants(objects: Variants){
        variants.append(objects)
    }
    func removeAAVariants(objects: Variants) {
        variants.remove(at: variants.firstIndex(of: objects)!)
    }


    //MARK: - DB Unloading
//    func unload(){
//        managedObjectContext = nil
//    }
    
}


public class CoreDataStack {
    public static let shared = CoreDataStack()
    public let persistentContainer: NSPersistentContainer
    public let context: NSManagedObjectContext

    private init() {
        // Create a managed object model
        let managedObjectModel = NSManagedObjectModel()
        
        // Create entities with attributes
        let makesEntity = NSEntityDescription()
        makesEntity.name = "Makes"
        makesEntity.managedObjectClassName = "Makes"
        
        // Add attributes to Makes entity
        let makeIdAttribute = NSAttributeDescription()
        makeIdAttribute.name = "makeId"
        makeIdAttribute.attributeType = .stringAttributeType
        makeIdAttribute.isOptional = true
        
        let makeNameAttribute = NSAttributeDescription()
        makeNameAttribute.name = "makeName"
        makeNameAttribute.attributeType = .stringAttributeType
        makeNameAttribute.isOptional = true
        
        makesEntity.properties = [makeIdAttribute, makeNameAttribute]
        
        // Create Models entity
        let modelsEntity = NSEntityDescription()
        modelsEntity.name = "Models"
        modelsEntity.managedObjectClassName = "Models"
        
        // Add attributes to Models entity
        let modelIdAttribute = NSAttributeDescription()
        modelIdAttribute.name = "modelId"
        modelIdAttribute.attributeType = .stringAttributeType
        modelIdAttribute.isOptional = true
        
        let modelNameAttribute = NSAttributeDescription()
        modelNameAttribute.name = "modelName"
        modelNameAttribute.attributeType = .stringAttributeType
        modelNameAttribute.isOptional = true
        
        let makeIdRefAttribute = NSAttributeDescription()
        makeIdRefAttribute.name = "makeId"
        makeIdRefAttribute.attributeType = .stringAttributeType
        makeIdRefAttribute.isOptional = true
        
        modelsEntity.properties = [modelIdAttribute, modelNameAttribute, makeIdRefAttribute]
        
        // Create Variants entity
        let variantsEntity = NSEntityDescription()
        variantsEntity.name = "Variants"
        variantsEntity.managedObjectClassName = "Variants"
        
        // Add attributes to Variants entity
        let variantIdAttribute = NSAttributeDescription()
        variantIdAttribute.name = "variantId"
        variantIdAttribute.attributeType = .stringAttributeType
        variantIdAttribute.isOptional = true
        
        let variantNameAttribute = NSAttributeDescription()
        variantNameAttribute.name = "variantName"
        variantNameAttribute.attributeType = .stringAttributeType
        variantNameAttribute.isOptional = true
        
        let modelIdRefAttribute = NSAttributeDescription()
        modelIdRefAttribute.name = "modelId"
        modelIdRefAttribute.attributeType = .stringAttributeType
        modelIdRefAttribute.isOptional = true
        
        variantsEntity.properties = [variantIdAttribute, variantNameAttribute, modelIdRefAttribute]
        
        // Create Ads entity
        let adsEntity = NSEntityDescription()
        adsEntity.name = "Ads"
        adsEntity.managedObjectClassName = "Ads"
        
        // Add attributes to Ads entity
        let adIdAttribute = NSAttributeDescription()
        adIdAttribute.name = "adId"
        adIdAttribute.attributeType = .stringAttributeType
        adIdAttribute.isOptional = true
        
        let titleAttribute = NSAttributeDescription()
        titleAttribute.name = "title"
        titleAttribute.attributeType = .stringAttributeType
        titleAttribute.isOptional = true
        
        let nameAttribute = NSAttributeDescription()
        nameAttribute.name = "name"
        nameAttribute.attributeType = .stringAttributeType
        nameAttribute.isOptional = true
        
        let priceAttribute = NSAttributeDescription()
        priceAttribute.name = "price"
        priceAttribute.attributeType = .stringAttributeType
        priceAttribute.isOptional = true
        
        let descriptionAttribute = NSAttributeDescription()
        descriptionAttribute.name = "adDescription"
        descriptionAttribute.attributeType = .stringAttributeType
        descriptionAttribute.isOptional = true
        
        let makeAttribute = NSAttributeDescription()
        makeAttribute.name = "make"
        makeAttribute.attributeType = .stringAttributeType
        makeAttribute.isOptional = true
        
        let modelAttribute = NSAttributeDescription()
        modelAttribute.name = "model"
        modelAttribute.attributeType = .stringAttributeType
        modelAttribute.isOptional = true
        
        let variantAttribute = NSAttributeDescription()
        variantAttribute.name = "variant"
        variantAttribute.attributeType = .stringAttributeType
        variantAttribute.isOptional = true
        
        let yearAttribute = NSAttributeDescription()
        yearAttribute.name = "year"
        yearAttribute.attributeType = .stringAttributeType
        yearAttribute.isOptional = true
        
        let kmAttribute = NSAttributeDescription()
        kmAttribute.name = "km"
        kmAttribute.attributeType = .stringAttributeType
        kmAttribute.isOptional = true
        
        let fuelAttribute = NSAttributeDescription()
        fuelAttribute.name = "fuel"
        fuelAttribute.attributeType = .stringAttributeType
        fuelAttribute.isOptional = true
        
        let transmissionAttribute = NSAttributeDescription()
        transmissionAttribute.name = "transmission"
        transmissionAttribute.attributeType = .stringAttributeType
        transmissionAttribute.isOptional = true
        
        let colorAttribute = NSAttributeDescription()
        colorAttribute.name = "color"
        colorAttribute.attributeType = .stringAttributeType
        colorAttribute.isOptional = true
        
        let bodyTypeAttribute = NSAttributeDescription()
        bodyTypeAttribute.name = "bodyType"
        bodyTypeAttribute.attributeType = .stringAttributeType
        bodyTypeAttribute.isOptional = true
        
        let locationAttribute = NSAttributeDescription()
        locationAttribute.name = "location"
        locationAttribute.attributeType = .stringAttributeType
        locationAttribute.isOptional = true
        
        let imageUrlAttribute = NSAttributeDescription()
        imageUrlAttribute.name = "imageUrl"
        imageUrlAttribute.attributeType = .stringAttributeType
        imageUrlAttribute.isOptional = true
        
        adsEntity.properties = [
            adIdAttribute, 
            titleAttribute, 
            nameAttribute,
            priceAttribute, 
            descriptionAttribute,
            makeAttribute,
            modelAttribute,
            variantAttribute,
            yearAttribute,
            kmAttribute,
            fuelAttribute,
            transmissionAttribute,
            colorAttribute,
            bodyTypeAttribute,
            locationAttribute,
            imageUrlAttribute
        ]

        // Create LeadStatus entity
        let leadStatusEntity = NSEntityDescription()
        leadStatusEntity.name = "LeadStatus"
        leadStatusEntity.managedObjectClassName = "LeadStatus"
        
        let leadStatusNameAttribute = NSAttributeDescription()
        leadStatusNameAttribute.name = "name"
        leadStatusNameAttribute.attributeType = .stringAttributeType
        leadStatusNameAttribute.isOptional = true
        
        leadStatusEntity.properties = [leadStatusNameAttribute]

        // Create SubLeads entity
        let subLeadsEntity = NSEntityDescription()
        subLeadsEntity.name = "SubLeads"
        subLeadsEntity.managedObjectClassName = "SubLeads"
        
        let subLeadsNameAttribute = NSAttributeDescription()
        subLeadsNameAttribute.name = "name"
        subLeadsNameAttribute.attributeType = .stringAttributeType
        subLeadsNameAttribute.isOptional = true
        
        subLeadsEntity.properties = [subLeadsNameAttribute]

        // Create States entity
        let statesEntity = NSEntityDescription()
        statesEntity.name = "States"
        statesEntity.managedObjectClassName = "States"
        
        let statesNameAttribute = NSAttributeDescription()
        statesNameAttribute.name = "name"
        statesNameAttribute.attributeType = .stringAttributeType
        statesNameAttribute.isOptional = true
        
        statesEntity.properties = [statesNameAttribute]

        // Create Cities entity
        let citiesEntity = NSEntityDescription()
        citiesEntity.name = "Cities"
        citiesEntity.managedObjectClassName = "Cities"
        
        let citiesNameAttribute = NSAttributeDescription()
        citiesNameAttribute.name = "name"
        citiesNameAttribute.attributeType = .stringAttributeType
        citiesNameAttribute.isOptional = true
        
        citiesEntity.properties = [citiesNameAttribute]
        
        // Create relationships between States and Cities
        let citiesRelationship = NSRelationshipDescription()
        citiesRelationship.name = "cities"
        citiesRelationship.destinationEntity = citiesEntity
        citiesRelationship.inverseRelationship = nil
        citiesRelationship.maxCount = 0
        citiesRelationship.minCount = 0
        citiesRelationship.isOptional = true
        citiesRelationship.deleteRule = .nullifyDeleteRule
        
        let statesRelationship = NSRelationshipDescription()
        statesRelationship.name = "states"
        statesRelationship.destinationEntity = statesEntity
        statesRelationship.inverseRelationship = citiesRelationship
        statesRelationship.maxCount = 1
        statesRelationship.minCount = 0
        statesRelationship.isOptional = true
        statesRelationship.deleteRule = .nullifyDeleteRule
        
        citiesRelationship.inverseRelationship = statesRelationship
        
        statesEntity.properties = [statesNameAttribute, citiesRelationship]
        citiesEntity.properties = [citiesNameAttribute, statesRelationship]
        
        // Create relationships between LeadStatus and SubLeads
        let subleadsRelationship = NSRelationshipDescription()
        subleadsRelationship.name = "subleads"
        subleadsRelationship.destinationEntity = subLeadsEntity
        subleadsRelationship.inverseRelationship = nil
        subleadsRelationship.maxCount = 0
        subleadsRelationship.minCount = 0
        subleadsRelationship.isOptional = true
        subleadsRelationship.deleteRule = .nullifyDeleteRule
        
        let leadstatusRelationship = NSRelationshipDescription()
        leadstatusRelationship.name = "leadstatus"
        leadstatusRelationship.destinationEntity = leadStatusEntity
        leadstatusRelationship.inverseRelationship = subleadsRelationship
        leadstatusRelationship.maxCount = 1
        leadstatusRelationship.minCount = 0
        leadstatusRelationship.isOptional = true
        leadstatusRelationship.deleteRule = .nullifyDeleteRule
        
        subleadsRelationship.inverseRelationship = leadstatusRelationship
        
        leadStatusEntity.properties = [leadStatusNameAttribute, subleadsRelationship]
        subLeadsEntity.properties = [subLeadsNameAttribute, leadstatusRelationship]
        
        // Add entities to the model
        managedObjectModel.entities = [makesEntity, modelsEntity, variantsEntity, adsEntity, leadStatusEntity, subLeadsEntity, statesEntity, citiesEntity]
        
        // Create the persistent container with our model
        persistentContainer = NSPersistentContainer(name: "InventorySwiftModel", managedObjectModel: managedObjectModel)
        
        // Load the persistent stores
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                print("Error loading persistent stores: \(error)")
                fatalError("Unresolved error \(error), \(error.localizedDescription)")
            }
            print("Successfully loaded persistent stores")
        }
        
        // Set up the context
        context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
    }

    public func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

//public class CoreDataStack {
//    public static let shared = CoreDataStack()
//
//    public let persistentContainer: NSPersistentContainer
//
//    private init() {
//        let modelURL = Bundle(for: CoreDataStack.self).url(forResource: "InventorySwiftModel", withExtension: "momd")!
//        let model = NSManagedObjectModel(contentsOf: modelURL)
//        persistentContainer = NSPersistentContainer(name: "InventorySwiftModel", managedObjectModel: model!)
//        persistentContainer.loadPersistentStores { (description, error) in
//            if let error = error {
//                fatalError("Failed to load Core Data stack: \(error)")
//            }
//        }
//    }
//
//    public var context: NSManagedObjectContext {
//        return persistentContainer.viewContext
//    }
//}


//class CoreDataStack {
//    public static let shared = CoreDataStack()
//
//    public let persistentContainer: NSPersistentContainer
//
//    
//    private init() {
//        persistentContainer = NSPersistentContainer(name: "InventorySwiftModel")
//        persistentContainer.loadPersistentStores { (description, error) in
//            if let error = error {
//                fatalError("Failed to load Core Data stack: \(error)")
//            }
//        }
//    }
//
//    public var context: NSManagedObjectContext {
//        return persistentContainer.viewContext
//    }
//}
