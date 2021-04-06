//
//  DataBaseManager.swift
//  HealthKitTest
//
//  Created by Arseniy Oddler on 4/5/21.
//

import CoreData
import SwiftUI

class DataBaseManager {
    
    @Environment(\.managedObjectContext) var context
    
    func addCustomer(name: String, phone: String) {
        let person = Customer(context: context)
        person.id = UUID()
        person.name = name
        person.phone = phone

        saveContext()
    }

    func getAllCustomers() -> [Customer] {
        return fetchData()
    }
    
    private func fetchData() -> [Customer] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Customer")
        var result: [Customer] = []
        request.returnsObjectsAsFaults = false
        do {
            guard let res = try context.fetch(request) as? [Customer] else {
                print("Fetching data is not correct")
                return result
            }
            result = res
        } catch {
            print("Failed fetching data of garments")
        }
        return result
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }

//    func deleteAllEntities() {
//        let entities = appDelegate.persistentContainer.managedObjectModel.entities
//        for entity in entities {
//            if let name = entity.name {
//                delete(entityName: name)
//            }
//        }
//    }
//
//    func delete(at index: Int, from garments: [Garment]) {
//        guard let currentContext = context else {
//            print("Context is nil")
//            return
//        }
//        let itemToDelete = garments[index]
//        currentContext.delete(itemToDelete)
//    }
//
//    func delete(entityName: String) {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        do {
//            try appDelegate.persistentContainer.viewContext.execute(deleteRequest)
//        } catch let error as NSError {
//            debugPrint(error)
//        }
//    }
}

