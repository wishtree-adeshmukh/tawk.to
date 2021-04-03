//
//  ViewController.swift
//  twak
//
//  Created by Archana on 01/04/21.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var imgHView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var followingLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var companyLbl: UILabel!
    @IBOutlet weak var blogLbl: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var containView: UIView!
    
    @IBAction func SaveBtnClicked(_ sender: UIBarButtonItem) {
        if textView.text.isEmpty{
            let alert = UIAlertController(title: "Note is blank", message: "Please add Note", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else{
            userViewModel?.saveNote(note: textView.text)
        }
        
    }
    
    var userViewModel : UserViewModel?
    var userId: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        userViewModel = UserViewModel(userId)
        userViewModel!.userDelegats = self
        userViewModel!.userImageDelegets = self
        startShimmering()
        imgHView.makeCircle()
        imgHView.dropShadow()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.cornerRadius = 5
        initalies(forField: textView)
        userViewModel?.fetchUserDetails()
        // (self.noteTxtview.textColor == UIColor.lightGray) ? "" : self.noteTxtview.text!
        self.containView.frame = CGRect(x: 0, y: 0, width: self.scrollView.frame.size.width ,height: 1000)
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width ,height: 1000)
        imgView.startShimmeringEffect()
        userViewModel?.getProfileImage()
        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func startShimmering() {
        
        followersLbl.startShimmeringEffect()
        followingLbl.startShimmeringEffect()
        nameLbl.startShimmeringEffect()
        companyLbl.startShimmeringEffect()
        blogLbl.startShimmeringEffect()
        textView.startShimmeringEffect()
    }
    func endShimmering() {
        
        followersLbl.stopShimmeringEffect()
        followingLbl.stopShimmeringEffect()
        nameLbl.stopShimmeringEffect()
        companyLbl.stopShimmeringEffect()
        blogLbl.stopShimmeringEffect()
        textView.stopShimmeringEffect()
    }
    /**
     add tool bar with cancel and done button as AccessoryView for number pad input view
     - Parameter field: UITextField
     */
    func initalies(forField  field: UITextView) {
        let toolbar = UIToolbar()
        toolbar.tintColor = UIColor(named: "twakGreen")
        toolbar.barStyle = UIBarStyle.default
        let cancelBtn =  UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismiss(_:)))
        cancelBtn.tintColor = UIColor(named: "twakGreen")
        let doneBtn =  UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismiss(_:)))
        doneBtn.tintColor = UIColor(named: "twakGreen")
        toolbar.items = [
            cancelBtn,
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil),
            doneBtn
        ]
        toolbar.sizeToFit()
        field.inputAccessoryView = toolbar
    }
    /**
     quantity field cancel or done click from input accessory view it will end editing of contact field
     - Parameter sender: done or cancel button of click
     */
    @objc func dismiss(_ sender: UIBarButtonItem) {
        textView.endEditing(true)
    }
    
}
extension ViewController: UITextViewDelegate {
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: -200)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: 200)
    }
}
extension ViewController: UserDetailDelegets,UserImageDelegets {
    func imageDownloaded(_ imgData: Data, forUser userLogin: String) {
        if userViewModel?.userItem.login == userLogin {
            DispatchQueue.main.async {
                self.imgView.stopShimmeringEffect()
                self.imgView.image = UIImage(data: imgData)
            }
        }
    }
    
    func imageDownloadFiled(_ msg: String) {
        
    }
    
    func userDetailFechingFiled(_ msg: String) {
        
    }
    
    func userDetailsFechingSuccess() {
        DispatchQueue.main.async { [self] in
            endShimmering()
            followersLbl.text = "Followers \n \(userViewModel?.userItem.followers ?? 0)"
            followingLbl.text = "Following \n \(userViewModel?.userItem.followers ?? 0)"
            nameLbl.text = userViewModel?.userItem.login
            companyLbl.text = userViewModel?.userItem.company
            blogLbl.text = userViewModel?.userItem.blog
            textView.text = userViewModel?.userItem.note ?? ""
        }
    }
    
    func noteUpdated() {
        let alert = UIAlertController(title: "Success", message: "Note added successfully", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
