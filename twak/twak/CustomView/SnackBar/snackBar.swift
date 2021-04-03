//
//  snackBar.swift
//  connect
//
//  Created by Archana on 24/05/16.
//  Copyright © 2016 Wishtree. All rights reserved.
//

import UIKit
/// snack bar which will be visible at botton of all screens if tere is no internet
class SnackBar: UIView {
    /// message lable on snack bar
    @IBOutlet weak var msgLbl: UILabel!
    /// background view of snake bar
    var view: UIView!
    /// nib name of snack bar
    var nibName: String = "SnackBar"
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
        //fatalError("init(coder:) has not been implemented")
    }
    /**
     load view from nib file
     - Returns: view from nib
     */
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        // MARK: constant str
        self.msgLbl.text = "Unable to reach our servers. Please check your internet connection and try again."
        return view
    }
    /// set up view and added to parant
    func setUp() {
        view = loadViewFromNib()
        view.frame = bounds
        //   view.autoresizingMask = UIViewAutoresizing.FlexibleWidth |  UIViewAutoresizing.FlexibleHeight
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
    }
    /**
     create and show or hide snack bar
     - Parameter show: flag to set snack bar hiden or visible
     */
    func snackBarNeedToBe(show: Bool) {
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        switch show {
        case true:
            let snackBar = (keyWindow?.rootViewController?.view.subviews.last)! as UIView
            if snackBar.tag != 11 {
                let  snackBar1 = SnackBar(frame: CGRect(x: 0, y: (keyWindow?.rootViewController!.view.frame.height)! - 70, width: (keyWindow?.rootViewController!.view.frame.width)!, height: 70))
                snackBar1.tag = 11
                keyWindow?.rootViewController?.view.addSubview(snackBar1)
            }
        case false:
            let snackBar =   (keyWindow?.rootViewController?.view.subviews.last)
            if snackBar?.tag == 11 {
                snackBar?.removeFromSuperview()
            }
        }
    }
}
