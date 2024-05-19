//
//  ViewController.swift
//  CoreData_Sample
//
//  Created by ajay on 18/05/24.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var stdArr = [StudentModel]()
    var coreDataManager = CoreDataManager.shared
    
    var result = [StudentTbl]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let _ = self.coreDataManager.getCoreDataFilePath()
        
        self.getDataModel()
        
//        self.instertDB()
//        self.instertDB()

//        self.deleteRecord()

//        self.updateRecords()
        
//        self.coreDataManager.deleteAllData(entityName: .studentTbl)
                
//        self.fetchDataFromDB()
        
//        self.fetchSpecificStudent(studentID: 1)
        
        self.removeDuplicates()
    }

    func getDataModel() {
        self.stdArr = StudentModel().getData(count: 5)
    }
    
    func instertDB() {
        
        for data in self.stdArr {
            
            let studentTbl = StudentTbl(context: self.coreDataManager.context)
            studentTbl.id = Int16(data.id ?? 0)
            studentTbl.name = data.name
                                    
            let marksTbl = MarksTbl(context: self.coreDataManager.context)
            marksTbl.tel = Int32(data.marks?.tel ?? 0)
            marksTbl.eng = Int32(data.marks?.eng ?? 0)
            marksTbl.maths = Int32(data.marks?.maths ?? 0)
            
            studentTbl.addToOfMarks(marksTbl)
            
            do {
                try coreDataManager.context.save()
                print("Inserted")
            }catch {
                print("Error while inserting \(error)")
            }
        }
        
    }
    
    func fetchDataFromDB() {
        
        self.result = self.coreDataManager.fetch(entityName: .studentTbl)
        
        for data in self.result {
            print("\(data.id) -> \(data.name ?? "-")")
        }
    }
    
    func fetchSpecificStudent(studentID: Int) {
        
        let predicate = NSPredicate(format: "id == %d", studentID)
        let resultStd: [StudentTbl] = self.coreDataManager.fetch(entityName: .studentTbl, predicate: predicate)
        
        for std in resultStd {
            print("\(std.id) -> \(std.name ?? "-")")
            print(std.ofMarks?.count as Any)
            print(std.ofMarks as Any)
            
            print("--- MARKS ---")
            let marksPredicate = NSPredicate(format: "ofStudent == %@", std)
            let marksList: [MarksTbl] = self.coreDataManager.fetch(entityName: .marksTbl, predicate: marksPredicate)
            
            print(marksList)
            
            print("----------")
            for marks in marksList {
                print("Telugu = \(marks.tel)")
                print("English = \(marks.eng)")
                print("Maths = \(marks.maths)")
            }
        }
    }
    
    func deleteRecord() {
        
//        let predicate = NSPredicate(format: "attributeName == %@", "value")

        let predicate = NSPredicate(format: "id == %d", 3)
        if let deleteObj = self.coreDataManager.fetch(entityName: .studentTbl, predicate: predicate) as? [StudentTbl] {
            
            if let obj = deleteObj.first {
                self.coreDataManager.deleteRecord(object: obj)
            }
            
        }
    }
    
    func updateRecords() {
        
        let predicate = NSPredicate(format: "id == %d", 2)
        
        if let updateRecord = self.coreDataManager.fetch(entityName: .studentTbl, predicate: predicate) as? [StudentTbl] {
            
            if updateRecord.isEmpty == false {
                
                for i in 0..<updateRecord.count {
                    
                    updateRecord[i].id = 3
                    updateRecord[i].name = "A-3 Updated"
                    
                }
                
                self.coreDataManager.saveContext()
            }
        }
    }
    
    func removeDuplicates() {
        
        let uniqueIDsResult: [NSDictionary] = self.coreDataManager.fetchDistinct(attributeName: "id", entityName: .studentTbl, context: self.coreDataManager.context)
        
        print(uniqueIDsResult.count)
        
        let uniqueResult = uniqueIDsResult.map({ $0.value(forKey: "id") })
        
        var uniqueRecords: [StudentTbl] = [StudentTbl]()
        
        for i in uniqueResult {
            
            let predicate = NSPredicate(format: "id == %d", (i as? Int)!)
            let record: [StudentTbl] = self.coreDataManager.fetch(entityName: .studentTbl, predicate: predicate)
//            print(record.first?.name)
//            uniqueRecords.append(record[0])
        }
        
        for std in uniqueRecords {
            print(std.name!)
        }
        
        self.coreDataManager.deleteAllData(entityName: .studentTbl)
        
        for std in uniqueRecords {
            print(std.name!)
        }
        
        for data in uniqueRecords {
            
            let studentTbl = StudentTbl(context: self.coreDataManager.context)
            studentTbl.id = Int16(data.id)
            studentTbl.name = data.name
            
            do {
                try coreDataManager.context.save()
                print("Inserted")
            }catch {
                print("Error while inserting \(error)")
            }
        }
        
    }
}

