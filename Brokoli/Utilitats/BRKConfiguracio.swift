//
//  BRKConfiguracio.swift
//  Brokoli
//
//  Created by Sergi Ranís i Nebot on 16/6/17.
//  Copyright © 2017 Asilisoft. All rights reserved.
//

import Foundation
import UIKit
import Cloudinary


class BRKConfiguracio {

    static let shared = BRKConfiguracio()
    
    var colorPrincipal: UIColor?
    var colorTextSobrePrincipal: UIColor?
    var urlManufacturers: String?
    var urlManufacturersModels: String?
    var cloudinaryManufacturersLogosFolder: String?
    var cloudinaryUploadFolder: String?
    var cloudinary: CLDCloudinary?
    
    private var cloudinaryApiKey: String?
    private var cloudinaryApiSecret: String?
    private var cloudinaryCloudName: String?
    
    
    
    init() {
        if let path = Bundle.main.path(forResource: "Configuracio", ofType: "plist") {
            let configuracio = NSDictionary(contentsOfFile: path)
            
            
            // Recorrem totes les claus del fitxer de configuració
            for keyAny in configuracio!.allKeys {
                let key = keyAny as! String
                
                if key == "COLOR_PRINCIPAL" {
                    let strTemp = configuracio!["COLOR_PRINCIPAL"] as! String
                    colorPrincipal = UIColor(hexString: strTemp)
                }
                else if key == "COLOR_TEXT_SOBRE_PRINCIPAL" {
                    let strTemp = configuracio!["COLOR_TEXT_SOBRE_PRINCIPAL"] as! String
                    colorTextSobrePrincipal = UIColor(hexString: strTemp)
                }
                else if key == "URL_MANUFACTURERS" {
                    urlManufacturers  = (configuracio!["URL_MANUFACTURERS"] as! String)
                }
                else if key == "URL_MANUFACTURERS_MODELS"{
                    urlManufacturersModels  = (configuracio!["URL_MANUFACTURERS_MODELS"] as! String)
                }
                else if key == "COLOR_NAVBAR_FONS" {
                    let strTemp = configuracio!["COLOR_NAVBAR_FONS"] as! String
                    UINavigationBar.appearance().barTintColor = UIColor(hexString: strTemp)
                }
                else if key == "CLOUDINARY_API_KEY" {
                    cloudinaryApiKey  = (configuracio!["CLOUDINARY_API_KEY"] as! String)
                }
                else if key == "CLOUDINARY_API_SECRET" {
                    cloudinaryApiSecret  = (configuracio!["CLOUDINARY_API_SECRET"] as! String)
                }
                else if key == "CLOUDINARY_CLOUD_NAME" {
                    cloudinaryCloudName  = (configuracio!["CLOUDINARY_CLOUD_NAME"] as! String)
                }
                else if key == "CLOUDINARY_MANUFACTURERS_LOGOS_FOLDER" {
                    cloudinaryManufacturersLogosFolder  = (configuracio!["CLOUDINARY_MANUFACTURERS_LOGOS_FOLDER"] as! String)
                }
                else if key == "CLOUDINARY_UPLOAD_FOLDER" {
                    cloudinaryUploadFolder  = (configuracio!["CLOUDINARY_UPLOAD_FOLDER"] as! String)
                }
                else if key == "COLOR_NAVBAR_TEXT" {
                    let strTemp = configuracio!["COLOR_NAVBAR_TEXT"] as! String
                    UINavigationBar.appearance().tintColor = UIColor(hexString: strTemp)
                    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor(hexString: strTemp)]
                }
                else {
                    // Faig petar expressament la app per tal que el programador se'n adoni.
                    print("La key '\(key)' no està processada al fitxer BRKConfiguracio.swift")
                    let array = [""]
                    print(array[1])
                }
            }
            
            
            // Creem el CLDCloudinary
            if let apiKey = cloudinaryApiKey,
               let apiSecret = cloudinaryApiSecret,
               let cloudName = cloudinaryCloudName {
                    let urlAccount = "cloudinary://\(apiKey):\(apiSecret)@\(cloudName)"
                    if let config = CLDConfiguration(cloudinaryUrl: urlAccount) {
                        cloudinary = CLDCloudinary(configuration: config)
                    }
                
            } else {
                // Faig petar expressament la app per tal que el programador se'n adoni.
                print("Falta alguna info de Cloudinay al fitxer Configuracio.plist")
                let array = [""]
                print(array[1])
            }
        }
    }
}
