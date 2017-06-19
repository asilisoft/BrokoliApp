//
//  BRKUtilitats.swift
//  Brokoli
//
//  Created by Sergi Ranís i Nebot on 16/6/17.
//  Copyright © 2017 Asilisoft. All rights reserved.
//

import Foundation
import Alamofire
import UIKit




class BRKUtilitats {
    
    static func enfosquir(mostrarSpinner: Bool) {
        if let delegate = UIApplication.shared.delegate, let vista = delegate.window {
            
            // Si ja està enfosquit, no fem res
            if let _ = vista!.viewWithTag(343499576) {
                return
            }
            
            // Enfosquim
            let enfosquir = UIView(frame: CGRect(x: 0, y: 0, width: vista!.frame.size.width, height: vista!.frame.size.height))
            enfosquir.backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.5)
            enfosquir.tag = 343499576
            
            // Spinner
            if mostrarSpinner {
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
                spinner.startAnimating()
                spinner.center = enfosquir.center
                enfosquir.addSubview(spinner)
            }
            
            vista!.addSubview(enfosquir)
        }
    }
    
    
    
    static func desenfosquir(ambAnimacio: Bool) {
        if let delegate = UIApplication.shared.delegate, let vista = delegate.window {
            if let enfosquir = vista?.viewWithTag(343499576) {
                UIView.animate(withDuration: ambAnimacio ? 1 : 0,
                               animations: { enfosquir.alpha = 0 },
                               completion: { _ in enfosquir.removeFromSuperview() })
            }
        }
    }
    
    
    
    static func debugLog(text:Any, fileOriginal:String = #file, liniaOriginal:Int = #line)
    {
        #if DEBUG
            let file = (fileOriginal as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
            print("\(file) : \(liniaOriginal)\n\(text)\n")
        #endif
    }
    
    
    
    static func mostrarAlertaBasica(en viewController: UIViewController, ambElText: String) {
        let alert = UIAlertController(title: "general_informacion".localized,
                                      message: ambElText.localized,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "general_continuar".localized, style: .default, handler: nil)
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    
    
    // https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    
    static func cridarAlEndPoint(urlString: String,
                                 mostrarAlertesEnElVC: UIViewController?,
                                 completion: ((Any) -> Void)?,
                                 failure: ((Error) -> Void)?) {
        
        BRKUtilitats.enfosquir(mostrarSpinner: true)
        
        
        // https://github.com/Alamofire/Alamofire/blob/master/Documentation/Alamofire%204.0%20Migration%20Guide.md#errors
        Alamofire.request(urlString).responseJSON { response in
            
            // Desenfosquim la pantalla
            BRKUtilitats.desenfosquir(ambAnimacio: true)
            
            
            // Tot OK
            if response.result.isSuccess, let json = response.result.value {
                completion?(json)
                return
            }
            
            
            // Tenim error
            var statusCode = response.response?.statusCode
            var stringError: String?

    
            //TODO: S'ha de decidir dels següents errors quins podem mostrar per pantalla a l'usuari
            // En seran pocs, ja que bàsicament son tècnics i no li aporten res.
            // Tot i així, per ara els mostro tots.
            if let error = response.result.error as? AFError {
                statusCode = error._code
                
                switch error {
                case .invalidURL(let url):
                    stringError = "Invalid URL: \(url) - \(error.localizedDescription)"
                    
                case .parameterEncodingFailed(let reason):
                    stringError = "Parameter encoding failed: \(error.localizedDescription)"
                    stringError?.append("Failure Reason: \(reason)")
                    
                case .multipartEncodingFailed(let reason):
                    stringError = "Multipart encoding failed: \(error.localizedDescription)"
                    stringError?.append(" Failure Reason: \(reason)")
                    
                case .responseValidationFailed(let reason):
                    stringError = "Response validation failed: \(error.localizedDescription)"
                    stringError?.append(" Failure Reason: \(reason)")
                    
                    switch reason {
                    case .dataFileNil, .dataFileReadFailed:
                        stringError?.append(" Downloaded file could not be read")
                        
                    case .missingContentType(let acceptableContentTypes):
                        stringError?.append(" Content Type Missing: \(acceptableContentTypes)")
                        
                    case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                        stringError?.append(" Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                        
                    case .unacceptableStatusCode(let code):
                        stringError?.append(" Response status code was unacceptable: \(code)")
                        statusCode = code
                    }
                    
                case .responseSerializationFailed(let reason):
                    stringError = "Response serialization failed: \(error.localizedDescription)"
                    stringError?.append("Failure Reason: \(reason)")
                }
                
                if stringError == nil {
                    stringError = "Underlying error: \(String(describing: error.underlyingError))"
                } else {
                    stringError?.append(" Underlying error: \(String(describing: error.underlyingError))")
                }
                
                
            } else if let error = response.result.error as? URLError {
                stringError = "URLError occurred: \(error)"
            } else {
                stringError = "Unknown error: \(String(describing: response.result.error))"
            }
            
            print("Status Code: \(String(describing: statusCode))")
            
            
            if let vc = mostrarAlertesEnElVC {
                let alert = UIAlertController(title: "_ERROR_", message: stringError, preferredStyle: .alert)
                let action = UIAlertAction(title: "_Continuar_", style: .default, handler: nil)
                alert.addAction(action)
                
                vc.present(alert, animated: true, completion: nil)
            }
        }
    }
}






// https://stackoverflow.com/questions/25081757/whats-nslocalizedstring-equivalent-in-swift
extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}



// https://stackoverflow.com/questions/24263007/how-to-use-hex-colour-values-in-swift-ios
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}





