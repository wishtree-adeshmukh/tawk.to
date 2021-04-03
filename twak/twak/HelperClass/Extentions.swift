//
//  Extentions.swift
//  twak
//
//  Created by Archana on 01/04/21.
//

import Foundation
import UIKit

class FormTextField: UITextField {
    
    @IBInspectable var inset: CGFloat = 0
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: inset)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
}

extension UIImage {
    func inverseImage() -> UIImage? {
        let coreImage = UIKit.CIImage(image: self)
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        guard let result = filter.value(forKey: kCIOutputImageKey) as? UIKit.CIImage else { return nil }
        return UIImage(ciImage: result)
    }
}



extension UIView {
    /*
     this extension is added to draw shadow of view
     black shadow will draw with .5 radius to make this extention work you need to maintain 1 dp constain which will make shadow visible
     */
    func dropShadow() {
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 0.5
        layer.shadowOpacity = 0.7
        layer.shadowColor = UIColor.black.cgColor
    }
    /// this method will conert the view in cercle
    func makeCircle() {
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = frame.width/2
    }
    
    func startShimmeringEffect() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        let gradientColorOne = UIColor(named: "shimmerDarkColor")?.cgColor ?? UIColor(white: 0.90, alpha: 1.0).cgColor
        let gradientColorTwo = UIColor(named: "shimmerLightColor")?.cgColor ?? UIColor(white: 0.95, alpha: 1.0).cgColor
        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        self.layer.addSublayer(gradientLayer)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 1.25
        gradientLayer.name = "shimmer"
        gradientLayer.add(animation, forKey: animation.keyPath)
    }
    
    func stopShimmeringEffect() {
        if (self.layer.sublayers != nil) {
            for layer in self.layer.sublayers! {
                if layer.name == "shimmer" {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
}
