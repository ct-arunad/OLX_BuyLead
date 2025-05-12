//
//  Constant.swift
//  InventorySwift
//
//  Created by Vikram on 10/08/24.
//


import Foundation
import UIKit
struct Constant {
    static let OLXApi = "https://fcgapi.olx.in/dealer/mobile_api"
 //  static let OLXApi = "https://testolxapi4.cartradeexchange.com/mobile_api"
    static let uuid = UIDevice.current.identifierForVendor?.uuidString
}

extension UIColor {
    static let appPrimary = UIColor(red: 23.0/255.0, green: 73.0/255.0, blue: 152.0/255.0, alpha: 1.0)
    static let sendsms =  UIColor(red: 243/255, green: 245/255, blue: 246/255, alpha: 1.0)
    static let cellbg = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0)
}
enum AppFontStyle {
    case regular
    case bold
    case italic
    case medium
    case custom(String) // Optional: for custom font names
}
extension UIFont {
    static func appFont(_ style: AppFontStyle, size: CGFloat) -> UIFont {
        switch style {
        case .regular:
            return UIFont(name: "Roboto-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
        case .bold:
            return UIFont(name: "Roboto-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
        case .medium:
            return UIFont(name: "Roboto-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
        case .italic:
            return UIFont(name: "Roboto-Italic", size: size) ?? UIFont.italicSystemFont(ofSize: size)
        case .custom(let fontName):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }
    
    // Also fix these static properties
    static let RobotoRegular = UIFont(name: "Roboto-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .regular)
    static let RobotoBold = UIFont(name: "Roboto-Bold", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .bold)
}
extension UIButton {
    func addLeftAndRightBorders(color: UIColor, width: CGFloat) {
        // Left Border
        let leftBorder = CALayer()
        leftBorder.backgroundColor = color.cgColor
        leftBorder.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.height)
        self.layer.addSublayer(leftBorder)

        // Right Border
        let rightBorder = CALayer()
        rightBorder.backgroundColor = color.cgColor
        rightBorder.frame = CGRect(x: self.frame.width - width, y: 0, width: width, height: self.frame.height)
        self.layer.addSublayer(rightBorder)
    }
}
extension UIImage {
    func tinted(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return self }

        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)
        let rect = CGRect(origin: .zero, size: size)

        context.setBlendMode(.normal)
        context.draw(cgImage, in: rect)

        context.setBlendMode(.sourceIn)
        context.fill(rect)

        let coloredImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()

        return coloredImage
    }
}
