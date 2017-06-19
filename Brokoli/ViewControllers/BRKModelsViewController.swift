//
//  BRKModelsViewController.swift
//  Brokoli
//
//  Created by Sergi Ranís i Nebot on 17/6/17.
//  Copyright © 2017 Asilisoft. All rights reserved.
//

import UIKit
import Cloudinary
import AVFoundation


class BRKModelsViewController: UIViewController, UICollectionViewDataSource,
                               UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
                               UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var viewFonsCercador: UIView!
    @IBOutlet weak var txtCercador: UITextField!
    @IBOutlet weak var lblRuta: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var manufacturerName: String?       // Setejat a BRKManufacturersViewController
    var models: NSArray?                // Setejat a BRKManufacturersViewController
    
    var modelsFiltrats = [NSDictionary]()


    
    
    
    
    
    // MARK: - Bàsics del ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Inicialitzacions visuals de la pantalla
        viewFonsCercador.backgroundColor = BRKConfiguracio.shared.colorPrincipal
        textosDeLaPantalla()
        
        
        // Filtrem els models
        filtrarModels()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    // MARK: - Mètodes propis
    
    // Canvi d'idioma
    // Si l'app pot canviar d'idioma en qualsevol moment, va molt bé tenir un mètode com aquest on estigui centralitzat
    func textosDeLaPantalla() {
        self.navigationItem.title = "tipo_seguro_header".localized
        lblRuta.text = ("tipo_seguro_coche".localized).appending(" > \(manufacturerName!.capitalized) >")
        
        let str = NSAttributedString(string: "manufac_buscar".localized,
                                     attributes: [NSForegroundColorAttributeName: UIColor.white])
        txtCercador.attributedPlaceholder = str
    }
    
    @IBAction func filtrarModels() {
        
        modelsFiltrats.removeAll()
        
        for m in models! {
            let model = m as! NSDictionary
            
            //TODO: Pendent de confirmar amb el PO que si 'active' = 0 no l'hem d'incloure
            // per ara els estic filtrant aquí. Però si confirmen que s'ha de fer, per eficiència
            // ho hauriem de fer d'entrada i no cada cop que l'usuari modifica la cadena de cerca.
            if !(model["active"] as! Bool) {
                continue
            }
            
            
            // Eliminem aquells que el nom no continguin la cadena escrita per l'usuari
            if let searchString = txtCercador.text?.lowercased() {
                if searchString.characters.count != 0 {
                    let name = (model["name"] as! String).lowercased()
                    
                    guard name.contains(searchString) else {
                        continue
                    }
                }
            }
            
            
            // Ha passat tots els filtres
            modelsFiltrats += [model]
        }
        
        
        // Recarreguem la collectionView
        collectionView.reloadData()
    }
    
    @IBAction func tancarTeclat() {
        //TODO: Per ara tanco el teclat quan l'usuari prem 'done'
        // consultar amb UX si volen que es tanqui també si l'usuari prem fora d'ell.
        self.view.endEditing(true)
    }
    

    
    
    
    
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelsFiltrats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_model", for: indexPath)
        
        //TODO: Hi ha noms que queden tallats, parlar amb disseny com ho volen
        // Podem fer un pre-procés de mirar tots els noms i calcular la mida de la font per tal que hi càpiguen
        // i que tots es mostrin amb la mateixa mida
        let dictionary = modelsFiltrats[indexPath.row]
            
        // Nom del model
        (cell.viewWithTag(100) as! UILabel).text = (dictionary["name"] as! String).capitalized
        
        
        return cell
    }
    
    
    
    
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // El dispositiu te càmera?
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            BRKUtilitats.mostrarAlertaBasica(en: self, ambElText: "error_no_camera")
            return
        }
        
        
        // Demanem el permís
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
            
            // Si no el tenim, avisem a l'usuari que l'otorgui
            guard granted else {
                BRKUtilitats.mostrarAlertaBasica(en: self, ambElText: "models_no_camera")
                return
            }
            
            
            // Mostrem el UIImagePickerController
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    
    
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
        // Tanquem el picker
        imagePickerControllerDidCancel(picker)
        
        // Processem la foto feta
        if let foto = info["UIImagePickerControllerOriginalImage"] as? UIImage {

            // TODO: A l'intentar pujar una imatge a mida real, Cloudinary ha donat l'error
            //  File size too large. Got 12114362. Maximum is 10485760.
            // He buscat a la documentació oficial i per ara no donen suport per fer un resize
            // https://support.cloudinary.com/hc/en-us/articles/213625845-What-is-the-recommended-approach-for-resizing-large-images-during-the-upload-process-
            // Així que per ara, ho faig manualment
            
            let novaMida = CGSize(width: foto.size.width * 0.5, height: foto.size.height * 0.5)
            let thumbnail = BRKUtilitats.resizeImage(image: foto, targetSize: novaMida)
            
            if let imgData = UIImagePNGRepresentation(thumbnail),
               let cloudinary = BRKConfiguracio.shared.cloudinary {
                    BRKUtilitats.enfosquir(mostrarSpinner: true)
                    // TODO: Com la pujada pot tardar, s'ha d'afegir un missatge per l'usuari
                    //  o millor un abarra de progrès
                    cloudinary.createUploader().signedUpload(data: imgData,
                                                             params: nil,
                                                             progress: { (Progress) in
                                                                BRKUtilitats.debugLog(text: "\(Progress)")
                                                             },
                                                             completionHandler: { (result, error) in
                                                                BRKUtilitats.desenfosquir(ambAnimacio: true)
                                                                
                                                                if error != nil {
                                                                    BRKUtilitats.debugLog(text: "Error: \(String(describing: error!.userInfo["message"]))")
                                                                    BRKUtilitats.mostrarAlertaBasica(en: self,
                                                                                                     ambElText: "error_pujar_foto")
                                                                } else {
                                                                    BRKUtilitats.debugLog(text: "Upload OK. URL: \(String(describing: result?.url))")
                                                                    BRKUtilitats.mostrarAlertaBasica(en: self,
                                                                                                     ambElText: "models_pujada_ok")
                                                                }
                    })
            }
            else {
                // Tenim un error: o no hem pogut generar el NSData o no tenim CLDCloudinary
                BRKUtilitats.mostrarAlertaBasica(en: self, ambElText: "error_pujar_foto")
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Aquest mètode també el crido des de 
        // imagePickerController(UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
        // Si hi afegeixo més codi, verificar que és compatible amb aquesta crida.
        picker.dismiss(animated: true, completion: nil)
    }
}
