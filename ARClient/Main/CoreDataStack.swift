//
//  CoreDataStack.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 01.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//


import Foundation
import CoreData

import Foundation
import CoreData


final class CoreDataStack {


    static let store = CoreDataStack()
    private init() {}

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    var fetchedLoadObjects = [LoadObject]()

    func storeLoadObject(name: String, url: URL, data: Data, date: Date, filename: String, comment : String) {
//        guard let entity =  NSEntityDescription.entity(forEntityName: "LoadObject", in: context) else { return }
//        let property = NSManagedObject(entity: entity, insertInto: context)
//        property.setValue(name, forKey: "name")
//        property.setValue(date, forKey: "loadDate")
//        property.setValue(data, forKey: "data")
//        property.setValue(comment, forKey: "comment")
//        property.setValue(filename, forKey: "filename")
        let loadObject = LoadObject(context: context)
        loadObject.name = name
        loadObject.urlSource = url
        loadObject.loadDate = date
        loadObject.data = data
        loadObject.comment = comment
        loadObject.filename = filename
        saveContext()
        fetchLoadObjects()
 //       for loadObject in fetchedLoadObjects{
 //           print(loadObject.comment)
 //         print(loadObject.urlSource?.absoluteString)
 //       }
    }

    func fetchLoadObjects() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LoadObject")
        let dateSort = NSSortDescriptor(key:"loadDate", ascending:false)
        fetchRequest.sortDescriptors = [dateSort]
        self.fetchedLoadObjects = try! context.fetch(fetchRequest) as! [LoadObject]
    }

    func delete(loadObject: LoadObject) {
        context.delete(loadObject)
        try! context.save()
    }


    lazy var persistentContainer: CustomPersistantContainer = {

        let container = CustomPersistantContainer(name: "ARClientModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
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


class CustomPersistantContainer : NSPersistentContainer {

    static let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ru.denzu.ARClient.objects")!
    let storeDescription = NSPersistentStoreDescription(url: url)
    
    override class func defaultDirectoryURL() -> URL {
        return url
    }
}
