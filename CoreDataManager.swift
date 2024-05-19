//
//  CoreDataManager.swift
//  CoreData_Sample
//
//  Created by ajay on 18/05/24.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() { }
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "StudentModel")
        container.loadPersistentStores { persistentDescription, error in
            if let error = error {
                fatalError("Unresolved error \(error), \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    func instert<T: NSManagedObject>(entityName: EnitytNames, attributes: [String: Any]?) -> T? {
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName.rawValue, in: self.context) else {
            print("Unable to resolve entiry description \(entityName)")
            return nil
        }
        
        let newItem = NSManagedObject(entity: entityDescription, insertInto: self.context)
        guard let data = attributes else {
            print("error in Attributes")
            return nil
        }
        newItem.setValuesForKeys(data)
        
        return newItem as? T
        
    }
    
    func saveContext() {
        if self.context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Unresolved error \(error)")
            }
        }
    }
    
    func fetch<T: NSManagedObject>(entityName: EnitytNames, predicate: NSPredicate? = nil, sortDescriptor: [NSSortDescriptor]? = nil) -> [T] {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName.rawValue)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptor
        
//        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.resultType = .managedObjectResultType
//        fetchRequest.returnsDistinctResults = true
        
        do {
            let result = try context.fetch(fetchRequest)
            return (result as? [T]) ?? []
        }catch {
            print("Error fetching \(error)")
            
            return []
        }
        
    }
    
//    func fetchDistinct<T: NSManagedObject>(attributeName: String, entityName: EnitytNames, context: NSManagedObjectContext) -> [T]? {
//        
//        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: entityName.rawValue)
//        fetchRequest.resultType = .dictionaryResultType
//        fetchRequest.returnsDistinctResults = true
//        fetchRequest.propertiesToFetch = [attributeName]
//
//        do {
//            let results = try context.fetch(fetchRequest)
//            if let distinctValues = results.compactMap({ $0[attributeName] as? T }) {
//                return distinctValues
//            }
//        } catch {
//            print("Error fetching distinct values: \(error)")
//        }
//        return nil
//    }
    
    
    func fetchDistinct(attributeName: String, entityName: EnitytNames, context: NSManagedObjectContext) -> [NSDictionary] {
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: entityName.rawValue)
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsDistinctResults = true
        fetchRequest.propertiesToFetch = [attributeName]

        do {
            let results = try context.fetch(fetchRequest)
//            if let distinctValues = results.compactMap({ $0[attributeName] as? T }) as? [T] {
                return results
//            } else {
//                print("Error converting distinct values.")
//            }
        } catch {
            print("Error fetching distinct values: \(error)")
        }
        return [[:]]
    }
    
    func deleteRecord(object: NSManagedObject) {
        
        self.context.delete(object)
        do {
            try self.context.save()
        }catch {
            print("Error while deleting \(object)")
        }
    }
    
    // Function to delete all objects from an entity
    func deleteAllData(entityName: EnitytNames) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName.rawValue)
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                context.delete(objectData)
            }
            try context.save()
        } catch let error as NSError {
            print("Delete all data in \(entityName.rawValue) error : \(error) \(error.userInfo)")
        }
    }
    
    func getCoreDataFilePath() -> URL {
        let filePath = self.persistentContainer.persistentStoreDescriptions.first?.url
        
        print(filePath as Any)
        
        return filePath ?? URL(fileURLWithPath: "")
    }
}

enum EnitytNames: String {
    
    case studentTbl = "StudentTbl"
    case marksTbl = "MarksTbl"
}
