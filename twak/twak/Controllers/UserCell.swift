//
//  UserCell.swift
//  twak
//
//  Created by Archana on 01/04/21.
//

import UIKit


class UserCell: UITableViewCell {
    
    let noteImg : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "note")
        image.isHidden = true
        return image
    }()
    let nameLbl : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let imagView : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    let imageHView : UIView = {
        let holderV = UIView()
        holderV.translatesAutoresizingMaskIntoConstraints = false
        holderV.layer.cornerRadius = 25
        holderV.clipsToBounds = true
        return holderV
    }()
    let hView : UIView = {
        let holderV = UIView()
        holderV.translatesAutoresizingMaskIntoConstraints = false
        holderV.backgroundColor = UIColor.systemBackground
        holderV.layer.cornerRadius = 5
        return holderV
    }()
    func mainBackgroundHolderViewConstrains() -> [NSLayoutConstraint] {
        return[
            hView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            hView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -6),
            hView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 3),
            hView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -3)
        ]
    }
    func imageHolderviewConstrains() -> [NSLayoutConstraint] {
        return[
            imageHView.leadingAnchor.constraint(equalTo: self.hView.leadingAnchor, constant: 8),
            imageHView.topAnchor.constraint(equalTo: self.hView.topAnchor, constant: 8),
            imageHView.bottomAnchor.constraint(equalTo: self.hView.bottomAnchor, constant: -8),
            imageHView.widthAnchor.constraint(equalToConstant: 50),
            imageHView.heightAnchor.constraint(equalToConstant: 50),
            
        ]
    }
    func nameLblConstrains()  -> [NSLayoutConstraint] {
        return[
            nameLbl.leadingAnchor.constraint(equalTo: self.imageHView.trailingAnchor , constant: 10),
            //nameLbl.trailingAnchor.constraint(equalTo: self.hView.trailingAnchor, constant: -30),
            nameLbl.topAnchor.constraint(equalTo: imageHView.topAnchor, constant: 0),
            nameLbl.bottomAnchor.constraint(equalTo:  imageHView.bottomAnchor, constant: 0),
            imagView.widthAnchor.constraint(equalToConstant: 50),
            imagView.heightAnchor.constraint(equalToConstant: 50),
        ]
    }
    func noteimgConstrains() -> [NSLayoutConstraint] {
        return[
            noteImg.leadingAnchor.constraint(equalTo: nameLbl.trailingAnchor, constant: 8),
            noteImg.trailingAnchor.constraint(equalTo: self.hView.trailingAnchor, constant: -8),
            
            noteImg.widthAnchor.constraint(equalToConstant: 20),
            noteImg.heightAnchor.constraint(equalToConstant: 20),
            noteImg.centerYAnchor.constraint(equalTo: nameLbl.centerYAnchor),
            
        ]
    }
    private func constraintActivate() {
        NSLayoutConstraint.activate(mainBackgroundHolderViewConstrains())
        NSLayoutConstraint.activate(imageHolderviewConstrains())
        NSLayoutConstraint.activate(nameLblConstrains())
        NSLayoutConstraint.activate(noteimgConstrains())
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.secondarySystemBackground
        addSubview(hView)
        imageHView.addSubview(imagView)
        hView.addSubview(imageHView)
        hView.addSubview(noteImg)
        hView.addSubview(nameLbl)
        startShimmering()
        constraintActivate()
        
        //imageHView.makeCircle()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private var userViewModel : UserViewModel?
    private var rowIndex: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        hView.layer.cornerRadius = 5
        
        
        imagView.startShimmeringEffect()
        // Initialization code
    }
    
    func startShimmering() {
        imagView.startShimmeringEffect()
        nameLbl.startShimmeringEffect()
    }
    func stopShimmering() {
        imagView.stopShimmeringEffect()
        nameLbl.stopShimmeringEffect()
    }
    func initCellUI(with user: UserViewModel, androwIndex rowIndex: Int){
        stopShimmering()
        userViewModel = user
        self.rowIndex = rowIndex
        userViewModel?.userImageDelegets = self
        nameLbl.text = userViewModel?.userItem.login
        noteImg.isHidden = ( userViewModel?.userItem.note == nil)
        hView.backgroundColor = (( userViewModel?.userItem.is_viewed)!) ? UIColor.systemGray5 :UIColor.systemBackground
        imagView.startShimmeringEffect()
        userViewModel?.getProfileImage()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
extension UserCell :UserImageDelegets {
    func imageDownloaded(_ imgData: Data, forUser userLogin: String) {
        if userViewModel?.userItem.login == userLogin {
            DispatchQueue.main.async {
                self.imagView.stopShimmeringEffect()
                if  (self.rowIndex + 1).isMultiple(of: 4) {
                    self.imagView.image = UIImage(data: imgData)?.inverseImage()
                } else{
                    self.imagView.image = UIImage(data: imgData)
                }
                
            }
        }
    }
    
    
    func imageDownloadFiled(_ msg: String) {
        
    }
}
