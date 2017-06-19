//
//  BRKTipoSeguroViewController.swift
//  Brokoli
//
//  Created by Sergi Ranís i Nebot on 16/6/17.
//  Copyright © 2017 Asilisoft. All rights reserved.
//

import UIKit



class BRKTipoSeguroViewController: UIViewController {
    
    @IBOutlet weak var lblPregunta: UILabel?
    @IBOutlet weak var viewFonsPublicitat: UIView?
    @IBOutlet weak var lblPublicitat: UILabel?
    @IBOutlet weak var lblSegCoche: UILabel?
    @IBOutlet weak var lblSegVida: UILabel?
    @IBOutlet weak var lblSegSalud: UILabel?
    @IBOutlet weak var lblSegHogar: UILabel?
    @IBOutlet weak var lblSegMascotas: UILabel?
    @IBOutlet weak var lblSegOtros: UILabel?
    
    private var manufacturers: NSArray?
    
    
    
    // MARK: - Bàsics del ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Inicialitzacions visuals de la pantalla
        lblPregunta?.backgroundColor = BRKConfiguracio.shared.colorPrincipal
        lblPregunta?.textColor = BRKConfiguracio.shared.colorTextSobrePrincipal
        
        viewFonsPublicitat?.backgroundColor = BRKConfiguracio.shared.colorPrincipal
        
        lblPublicitat?.textColor = BRKConfiguracio.shared.colorTextSobrePrincipal
        
        textosDeLaPantalla()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Com només hi ha un segue, no hi ha possibilitat d'error, 
        // sempre anirem a BRKManufacturersViewController
        (segue.destination as! BRKManufacturersViewController).manufacturers = manufacturers
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
        lblPregunta?.text = "tipo_seguro_pregunta".localized
        lblPublicitat?.text = "tipo_seguro_publi".localized
        lblSegCoche?.text = "tipo_seguro_coche".localized
        lblSegVida?.text = "tipo_seguro_coche".localized
        lblSegSalud?.text = "tipo_seguro_coche".localized
        lblSegHogar?.text = "tipo_seguro_hogar".localized
        lblSegMascotas?.text = "tipo_seguro_mascotas".localized
        lblSegOtros?.text = "tipo_seguro_otros".localized
    }
    
    func processarRespostaEndPoint(json: Any) {
        
        // Verifiquem que la resposta és un Array
        if let tmp = json as? NSArray {
            manufacturers = tmp
            self.performSegue(withIdentifier: "segue_manufacturers", sender: nil)
        } else {
            BRKUtilitats.debugLog(text: "Ha passat alguna cosa rara, el servidor no ha retornat un NSArray!!")
            BRKUtilitats.mostrarAlertaBasica(en: self, ambElText: "general_reintentar")
        }
    }
    

    
    
    
    
    
    // MARK: - IBActions

    @IBAction func accioBtnSegCoche(sender: UIButton) {
        BRKUtilitats.cridarAlEndPoint(urlString: BRKConfiguracio.shared.urlManufacturers!,
                                      mostrarAlertesEnElVC: self,
                                      completion: processarRespostaEndPoint,
                                      // Per ara, tots els errors de connexió els mostro en un alertview
                                      failure: nil)
    }
    

    @IBAction func accioBtnNoImplementat(sender: UIButton) {
        BRKUtilitats.mostrarAlertaBasica(en: self, ambElText: "_NO IMPLEMENTAT_")
    }
    
}

