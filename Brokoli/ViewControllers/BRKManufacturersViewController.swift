//
//  BRKManufacturersViewController.swift
//  Brokoli
//
//  Created by Sergi Ranís i Nebot on 17/6/17.
//  Copyright © 2017 Asilisoft. All rights reserved.
//

import UIKit
import Cloudinary



class BRKManufacturersViewController: UIViewController, UICollectionViewDataSource,
                                      UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var viewFonsCercador: UIView!
    @IBOutlet weak var txtCercador: UITextField!
    @IBOutlet weak var lblRuta: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var manufacturers: NSArray?             // Setejat des de BRKTipoSeguroViewController
    
    var manufacturersFiltrats = [NSDictionary]()
    var models: NSArray?
    var manufacturerName: String?
    
    
    
    
    
    // MARK: - Bàsics del ViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Inicialitzacions visuals de la pantalla
        viewFonsCercador.backgroundColor = BRKConfiguracio.shared.colorPrincipal
        textosDeLaPantalla()
        
        
        // Filtrem els manufacturers
        filtrarManufacturers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Com només hi ha un segue, no hi ha possibilitat d'error,
        // sempre anirem a BRKModelsViewController
        (segue.destination as! BRKModelsViewController).models = models
        (segue.destination as! BRKModelsViewController).manufacturerName = manufacturerName
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
        lblRuta.text = ("tipo_seguro_coche".localized).appending(" >")

        let str = NSAttributedString(string: "manufac_buscar".localized,
                                     attributes: [NSForegroundColorAttributeName: UIColor.white])
        txtCercador.attributedPlaceholder = str
    }
    
    @IBAction func filtrarManufacturers() {
        
        manufacturersFiltrats.removeAll()
        
        for m in manufacturers! {
            let manufac = m as! NSDictionary
            
            //TODO: Pendent de confirmar amb el PO que si 'active' = 0 no l'hem d'incloure
            // per ara els estic filtrant aquí. Però si confirmen que s'ha de fer, per eficiència
            // ho hauriem de fer d'entrada i no cada cop que l'usuari modifica la cadena de cerca.
            if !(manufac["active"] as! Bool) {
                continue
            }
            
            
            // Eliminem aquells que el nom no continguin la cadena escrita per l'usuari
            if let searchString = txtCercador.text?.lowercased() {
                if searchString.characters.count != 0 {
                    let name = (manufac["name"] as! String).lowercased()
                    
                    guard name.contains(searchString) else {
                        continue
                    }
                }
            }
            

            // Ha passat tots els filtres
            manufacturersFiltrats += [manufac]
        }
        
        
        // Recarreguem la collectionView
        collectionView.reloadData()
    }
    
    @IBAction func tancarTeclat() {
        //TODO: Per ara tanco el teclat quan l'usuari prem 'done'
        // consultar amb UX si volen que es tanqui també si l'usuari prem fora d'ell.
        self.view.endEditing(true)
    }
    
    func processarRespostaEndPoint(json: Any) {
        
        // Verifiquem que la resposta és un Array
        if let tmp = json as? NSArray {
            models = tmp
            self.performSegue(withIdentifier: "segue_models", sender: nil)
        } else {
            BRKUtilitats.debugLog(text: "Ha passat alguna cosa rara, el servidor no ha retornat un NSArray!!")
            BRKUtilitats.mostrarAlertaBasica(en: self, ambElText: "general_reintentar")
        }
    }
    
    
    
    
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return manufacturersFiltrats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_manufacturer", for: indexPath)
        
        //TODO: Hi ha noms que queden tallats, parlar amb disseny com ho volen
        // Podem fer un pre-procés de mirar tots els noms i calcular la mida de la font per tal que hi càpiguen
        // i que tots es mostrin amb la mateixa mida
        let dictionary = manufacturersFiltrats[indexPath.row]
            
        // Nom del manufacturer
        (cell.viewWithTag(100) as! UILabel).text = (dictionary["name"] as! String).capitalized
        
        
        // Logo URL (Si el programador ha oblidat establir aquest valor en el fitxer de config, li petarà la app, cosa que ja està bé)
        let idManufac = (dictionary["id"] as! Int)
        let logosFolder = BRKConfiguracio.shared.cloudinaryManufacturersLogosFolder!
        let transformation = CLDTransformation().setWidth(140).setHeight(140).setCrop(.fit)
        let cloudinary = BRKConfiguracio.shared.cloudinary
        let url = cloudinary?.createUrl().setTransformation(transformation).generate("\(logosFolder)/\(idManufac).jpg")
        
        (cell.viewWithTag(300) as! UIImageView).image = nil
        (cell.viewWithTag(1000) as! UIActivityIndicatorView).startAnimating()
        
        
        cloudinary?.createDownloader().fetchImage(url!, { (Progress) in
            // No necessitem processar % de descàrrega
        }) { (responseImage, error) in
            DispatchQueue.main.async {
                if let logo = responseImage {
                        (cell.viewWithTag(300) as! UIImageView).image = logo
                } else {
                    //TODO: En el supòsit que no s'hagi pogut descarregar la imatge,
                    //  mostrar una per defecte. Demanar a disseny.
                }
                
                (cell.viewWithTag(1000) as! UIActivityIndicatorView).stopAnimating()
            }
        }

        
        return cell
    }
    
    
    

    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Nom del manufacturer
        manufacturerName = manufacturersFiltrats[indexPath.row]["name"] as? String
        
        // Generem la URL, amb el ID del manufacturer
        let idManufacturer = manufacturersFiltrats[indexPath.row]["id"]!
        var url = BRKConfiguracio.shared.urlManufacturersModels
        url = url?.replacingOccurrences(of: "{manufacturerId}", with: "\(idManufacturer)")
        
        BRKUtilitats.cridarAlEndPoint(urlString: url!,
                                      mostrarAlertesEnElVC: self,
                                      completion: processarRespostaEndPoint,
                                      // Per ara, tots els errors de connexió els mostro en un alertview
                                      failure: nil)
    }

}
