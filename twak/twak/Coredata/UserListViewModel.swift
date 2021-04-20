//
//  UserViewMdel.swift
//  twak
//
//  Created by Archana on 01/04/21.
//

import Foundation
protocol ListDelegation : AnyObject {
    func loadTable(usersAry: Array<UserItem>)
    func errorToload(error: String?)
    func showAlertMsg(msg:String)
    
}

class UserListViewModel : NSObject {
    private var userAry : Array<UserItem>?
    weak var listDelegate: ListDelegation?
    var isLoading = false
    var isSearch = false
    var localEntriesEnd = false
    func cellReuseIdentifier() -> String {
        return "UserCell"
    }
    func loadUser() {
        isSearch = false
        localEntriesEnd = false
        userAry = CoreDataHandler.sharedInstance.fetchUserItems()
        if userAry!.count == 0 {
            CoreDataHandler.sharedInstance.fetchUsersFromAPIsuccess(id: 0, completion: { [self] ary in
                userAry = ary
                listDelegate?.loadTable(usersAry:userAry!)
            }, error: { msg in
                self.listDelegate?.errorToload(error: msg)
            })
        } else if (userAry!.count > 0){
            listDelegate?.loadTable(usersAry:userAry!)
        }
        else{
            listDelegate?.errorToload(error: nil)
        }
    }
    func loadLocaldata() -> (needToLoad: Bool,idOflastRow :Int? ) {
        if !localEntriesEnd {
            let usersFromStorage = CoreDataHandler.sharedInstance.fetchNextUserItem(lastItemId:Int(userAry!.last!.id))
            if usersFromStorage.count == 0 {
                localEntriesEnd = true
                return(true, Int(userAry!.last!.id))
            }
            userAry?.append(contentsOf: usersFromStorage)
            self.listDelegate?.loadTable(usersAry:self.userAry!)
            if usersFromStorage.count < 10 {
                return(true, Int(usersFromStorage.last!.id))
            } else {
                return(false,nil)
            }
        }
        if !NetworkManager.sharedInstance.isOnline() {
            self.listDelegate?.showAlertMsg(msg: "We can not load a more users as your mobile data is off.")
            return(false,nil)
        }
        
        return(true,Int(userAry!.last!.id))
        
    }
    func numberOfRows() -> Int{
        return ((userAry?.count != nil) ? userAry!.count : 0) + (isSearch ? 0 : 1)
        
    }
    
    func userAt(index: Int) -> UserViewModel? {
        if (userAry?.count ?? 0 > 0) && userAry!.count > index {
            return UserViewModel(with: userAry![index])
        }
        //  else if (isLoading)
        return nil
        //  }
        //  fatalError("No GitHubUserViewModel found at index \(index)")
    }
    func loadNextpage(){
        if isSearch {
            return
        }
        if !isLoading {
            let needstoFetch : (needToLoad: Bool,idOflastRow :Int?) = loadLocaldata()
            if needstoFetch.needToLoad {
                isLoading = true
                CoreDataHandler.sharedInstance.fetchUsersFromAPIsuccess(id: needstoFetch.idOflastRow!, completion: {ary in
                    self.userAry?.append(contentsOf: ary)
                    self.listDelegate?.loadTable(usersAry:self.userAry!)
                    self.isLoading = false
                    self.localEntriesEnd = false
                }, error: {msg in
                    self.listDelegate?.showAlertMsg(msg: msg)
                    self.isLoading = false
                })
            }
        }
    }
    
    func searchUser(searchTxt:String) {
        isSearch = true
        userAry = CoreDataHandler.sharedInstance.searchUsersWithText(searchTxt, withContext: nil)
        listDelegate?.loadTable(usersAry:userAry!)
    }
}
