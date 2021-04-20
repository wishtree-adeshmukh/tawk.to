//
//  UserViewModel.swift
//  twak
//
//  Created by Archana on 01/04/21.
//

import Foundation
protocol UserDetailDelegets: AnyObject {
    func userDetailFechingFiled(_ msg: String)
    func userDetailsFechingSuccess()
    func noteUpdated()
}
protocol UserImageDelegets: AnyObject {
    func imageDownloaded(_ imgData: Data, forUser userLogin: String)
    func imageDownloadFiled(_ msg : String)
}
class UserViewModel: NSObject {
    var userItem : UserItem
    weak var userDelegats : UserDetailDelegets?
    weak var userImageDelegets : UserImageDelegets?
    init(_ id : String) {
        userItem = CoreDataHandler.sharedInstance.fetchUserItem(id, withContext: nil)!
    }
    init(with user : UserItem) {
        userItem = user
    }
    
    func fetchUserDetails() {
        if userItem.is_viewed {
            self.userDelegats?.userDetailsFechingSuccess()
        } else {
            
            CoreDataHandler.sharedInstance.fetchUserDetailsFromAPIsuccess(userName: userItem.login!, completion: {usr in
                self.userItem = usr
                self.userDelegats?.userDetailsFechingSuccess()
                
            }, error: {msg in
                self.userDelegats?.userDetailFechingFiled(msg)
            })
        }
    }
    
    func getProfileImage() {
        guard  userItem.avatar_url != nil, let imageUrl = URL(string: userItem.avatar_url!) else {
            return
        }
        let request = URLRequest(url: imageUrl)
        if let cacheResponse = WSManager.shared.cache.cachedResponse(for: request){
            userImageDelegets?.imageDownloaded(cacheResponse.data, forUser: userItem.login!)
            return
        }
        let operationRecord = DownloadOprationRecord(name: userItem.login!, urlRequest: request, completion: { [self] result in
            if case .success(let data) = result {
                userImageDelegets?.imageDownloaded(data, forUser: userItem.login!)
            }
        })
        let downloadOperation = DownloadOperation(operationRecord)
        if !QueueManager.sharedInstance.downloadQueue.operations.contains(downloadOperation){
            QueueManager.sharedInstance.addInDownloadQueue(downloadOperation)
        }
    }
    
    func saveNote(note: String) {
        self.userItem.note = note
        CoreDataHandler.sharedInstance.saveContext(context: CoreDataHandler.sharedInstance.managedObjectContext)
        self.userDelegats?.noteUpdated()
    }
}
