//
//  FontLoader.swift
//  OLX_BuyLeads
//
//  Created by Aruna on 26/03/25.
//

import Foundation
import UIKit

public class FontLoader {
    public static func registerFonts() {
           let fontNames = [
               "Roboto-Black",
               "Roboto-BlackItalic",
               "Roboto-Bold",
               "Roboto-BoldItalic",
               "Roboto-Italic",
               "Roboto-Light",
               "Roboto-LightItalic",
               "Roboto-Medium",
               "Roboto-MediumItalic",
               "Roboto-Regular",
               "Roboto-Thin",
               "Roboto-ThinItalic",
               "RobotoCondensed-Bold",
               "RobotoCondensed-BoldItalic",
               "RobotoCondensed-Italic",
               "RobotoCondensed-Light",
               "RobotoCondensed-LightItalic",
               "RobotoCondensed-Regular"
           ]

           for fontName in fontNames {
               registerFont(withName: fontName)
           }
       }
    public static func registerFont(withName name: String) {
        guard let fontURL = Bundle.framework.url(forResource: name, withExtension: "ttf") else {
            print("Failed to find font: \(name)")
            return
        }
        
        guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider) else {
            print("Failed to create font: \(name)")
            return
        }
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            print("Failed to register font: \(name)")
            if let error = error?.takeRetainedValue() {
                print("Error registering font: \(error)")
            }
        } else {
            print("Successfully registered font: \(name)")
        }
    }
}
