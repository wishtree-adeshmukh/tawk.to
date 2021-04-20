//
//  CoreDataHandler.swift
//  twak
//
//  Created by Archana on 01/04/21.
//

import Foundation
import UIKit
import CoreData

class CoreDataHandler: NSObject {
    let baseUrl =  "https://api.github.com/users?since=" //
    let detailUrl = "https://api.github.com/users/"
    
    static let sharedInstance = CoreDataHandler()
    private override init() {}
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "twak")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var writeContext : NSManagedObjectContext = {
        let backgroundContext = persistentContainer.newBackgroundContext()
        //    backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        //    backgroundContext.undoManager = nil
        return backgroundContext
    }()
    
    lazy var  managedObjectContext : NSManagedObjectContext = {
        //        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        //        persistentContainer.viewContext.undoManager = nil
        //        persistentContainer.viewContext.shouldDeleteInaccessibleFaults = true
        //        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        return persistentContainer.viewContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext (context : NSManagedObjectContext) {
        // let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func searchUsersWithText(_ text: String, withContext context: NSManagedObjectContext? ) -> Array<UserItem>?{
        let context = context ??  managedObjectContext
        var users : Array<UserItem>?
        let fetchRequest = UserItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: " login CONTAINS[cd] %@ OR note CONTAINS[cd] %@", text, text)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        users = try? (context.fetch(fetchRequest) as! Array<UserItem>)
        return users
    }
    
    func fetchUserItems()-> Array<UserItem> {
        let context = managedObjectContext
        var users : Array<UserItem>?
        let fetchRequest = UserItem.fetchRequest()
        fetchRequest.fetchLimit = 20
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.returnsObjectsAsFaults = false
        users = try? (context.fetch(fetchRequest) as! Array<UserItem>)
        return users ?? []
        
    }
    func fetchUserItem(_ id: String, withContext context: NSManagedObjectContext?) -> UserItem?{
        let context =  context ?? managedObjectContext
        var user : UserItem?
        let fetchRequest = UserItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let users = try! (context.fetch(fetchRequest) as! [UserItem])
        if (users.count > 0) {
            user = users[0]
        }
        return user
    }
    func fetchNextUserItem(lastItemId: Int)-> Array<UserItem> {
        let context = managedObjectContext
        var users : Array<UserItem>?
        let fetchRequest = UserItem.fetchRequest()
        fetchRequest.fetchLimit = 20
        fetchRequest.predicate = NSPredicate(format: "%K > %i", "id", lastItemId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.returnsObjectsAsFaults = false
        users = try? (context.fetch(fetchRequest) as! Array<UserItem>)
        return users ?? []
    }
    func fetchUsersFromAPIsuccess (id: Int ,completion: @escaping (Array<UserItem>) -> Void, error : @escaping (String) -> Void){
        let url = URL(string: baseUrl+"\(id)")!
        let fetchRecord = UserOprationRecord(url: url, completion: {
            result in
            switch result {
            case .success(let data):
                let ary = self.ParseJSONToCodedataAry(data: data)
                DispatchQueue.main.async {
                    completion(ary)
                }
            case .failure(_):
                error("Someting went wrong try again later.")
            }
            
        })
        let fetchOperation = FetchOpration(fetchRecord)
        if !QueueManager.sharedInstance.downloadQueue.operations.contains(fetchOperation){
            QueueManager.sharedInstance.addInDownloadQueue(fetchOperation)
        }
        
    }
    func fetchUserDetailsFromAPIsuccess (userName: String ,completion: @escaping (UserItem) -> Void, error : @escaping (String) -> Void){
        let url = URL(string: detailUrl+userName)!
        let fetchRecord = UserOprationRecord(url: url, completion: {
            result in
            switch result {
            case .success(let data):
                let ary = self.parseJSONToCodedataObject(data: data)
                DispatchQueue.main.async {
                    completion(ary)
                }
            case .failure(_):
                error("Someting went wrong try again later.")
            }
            
        })
        let fetchOperation = FetchOpration(fetchRecord)
        if !QueueManager.sharedInstance.downloadQueue.operations.contains(fetchOperation){
            QueueManager.sharedInstance.addInDownloadQueue(fetchOperation)
        }
        
    }
    func ParseJSONToCodedataAry(data : Data) -> Array<UserItem> {
        var userItems : Array<UserItem>?
        let decoder = JSONDecoder()
        CoreDataHandler.sharedInstance.writeContext.performAndWait {
            let managedObjectContext = CoreDataHandler.sharedInstance.writeContext
            guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
                fatalError("Failed to  load context Key")
            }
            decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
            do {
                let result = try decoder.decode([UserItem].self, from: data)
                userItems = result
                
                CoreDataHandler.sharedInstance.saveContext(context: CoreDataHandler.sharedInstance.writeContext)
            } catch let error {
                print("decoding error: \(error)")
            }
        }
        return userItems!
    }
    
    func parseJSONToCodedataObject(data : Data) -> UserItem {
        var userItem : UserItem?
        do {
            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String, Any>
            userItem = fetchUserItem((result["id"] as AnyObject).stringValue, withContext: nil)
            userItem!.is_viewed = true
            userItem?.blog = result["blog"] as? String
            userItem?.company = result["company"] as? String
            userItem?.followers = result["followers"] as? NSNumber
            userItem?.following = result["following"] as? NSNumber
            print(result)
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave:[NSUpdatedObjectsKey : [userItem!.objectID]],
                                                                   into: [CoreDataHandler.sharedInstance.writeContext])
            CoreDataHandler.sharedInstance.saveContext(context: userItem?.managedObjectContext ?? CoreDataHandler.sharedInstance.writeContext)
        } catch let error {
            print("decoding error: \(error)")
        }
        
        
        return userItem!
    }
    
    func deleteGitHubUser(_ user: UserItem) {
        let context = user.managedObjectContext!
        context.delete(user)
        CoreDataHandler.sharedInstance.saveContext(context:context )
    }
}

