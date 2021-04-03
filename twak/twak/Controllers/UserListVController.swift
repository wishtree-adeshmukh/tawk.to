//
//  UserListVController.swift
//  twak
//
//  Created by Archana on 01/04/21.
//

import UIKit

class UserListVController: UIViewController {
    
    @IBOutlet weak var userTable: UITableView!
    
    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkMsgLbl: UILabel!
    
    private var userListViewModel = UserListViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setfooter(foterStr: "loading...", Totable: userTable)
        userListViewModel.listDelegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(networkOnline),
                                               name: .Online,
                                               object: nil
        )
        userTable.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        userTable.estimatedRowHeight = 100.0
        //userTable.rowHeight = 70
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userListViewModel.loadUser()
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    /**
     set footer to table for no contacts
     - Parameter table: table to which you want to set footer
     */
    func setfooter(foterStr: String, Totable table: UITableView) {
        let lbl = UILabel(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width-10, height: 50))
        lbl.font = UIFont(name:lbl.font.familyName, size: 14)
        lbl.textColor = UIColor.gray
        //lbl.backgroundColor = UIColor(named: "twakLightGreen")
        lbl.text =  foterStr
        lbl.textAlignment = NSTextAlignment.center
        lbl.tag = 11
        table.tableFooterView = lbl
    }
    
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ViewController {
            let tuple = sender as! (String,String)
            vc.title = tuple.0
            vc.userId = tuple.1
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}
extension UserListVController : ListDelegation {
    func showAlertMsg(msg: String) {
//        TODO: Remove this protocol Snak bar used to notifiy user
//                DispatchQueue.main.async {
//                    if (self.presentingViewController == nil){
//                        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertController.Style.alert)
//                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
//                         self.present(alert, animated: true, completion: nil)
//                    }
//
//                }
    }
    
    func errorToload(error: String?) {
        DispatchQueue.main.async {
            if let msg = error{
                self.noNetworkMsgLbl.text = msg
            }
            self.noNetworkView.isHidden = false
        }
    }
    
    func loadTable(usersAry: Array<UserItem>) {
        DispatchQueue.main.async {
            self.userTable.reloadData()
        }
    }
    
}
extension UserListVController {
    @objc func networkOnline() {
        if !self.noNetworkView.isHidden {
            self.noNetworkView.isHidden = true
        }
    }
}

extension UserListVController :  UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !(searchBar.text?.isEmpty ?? false) {
            userListViewModel.searchUser(searchTxt: searchBar.text!)
            (userTable.tableFooterView as! UILabel).text  = userListViewModel.numberOfRows() > 0 ? "" :  "No results found"
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            setfooter(foterStr: "Loading . . .", Totable: userTable)
            userListViewModel.loadUser()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
extension UserListVController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userListViewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UserCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        
        if let userModel = userListViewModel.userAt(index: indexPath.row){
            cell.initCellUI(with: userModel, androwIndex: indexPath.row)
        }
        else {
            cell.startShimmering()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let userModel = userListViewModel.userAt(index: indexPath.row){
            performSegue(withIdentifier: "userDetails", sender:( userModel.userItem.login, String(userModel.userItem.id)))
        }
        
        
    }
    
}
extension UserListVController: UITableViewDataSourcePrefetching{
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        //self.view.endEditing(true)
        if indexPaths.contains(IndexPath(row:userListViewModel.numberOfRows()-1, section: 0)) {
            userListViewModel.loadNextpage()
        }
    }
    
}
