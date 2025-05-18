//
//  registrarPrimeraParteViewController.swift
//  CUYPAY
//
//  Created by KAWORU on 29/04/25.
//

import UIKit

class registrarPrimeraParteViewController: UIViewController, UITextFieldDelegate {
    
    var usuario = Usuario(
        nombre: "",
        apellidos: "",
        usuario: "",
        email: "",
        clave1: "",
        clave2: ""
    )
    
    @IBOutlet weak var nombreText: UITextField!
    
    @IBOutlet weak var apellidoText: UITextField!
    
    @IBOutlet weak var correoText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        agregarPaddingIzquierdo(nombreText)
        agregarPaddingIzquierdo(apellidoText)
        agregarPaddingIzquierdo(correoText)
        
        correoText.delegate = self
        correoText.keyboardType = .emailAddress
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "segundoRegistro" {
            if let destino = segue.destination as? registrarSegundaParteViewController{
                destino.usuario = usuario
                print(" Se está ejecutando prepare: \(usuario)")
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "segundoRegistro" {
            guard
                let nombre = nombreText.text, !nombre.isEmpty,
                let apellidos = apellidoText.text, !apellidos.isEmpty,
                let email = correoText.text, !email.isEmpty
            else {
                mostrarAlerta(titulo: "Error", mensaje: "Por favor, completa todos los campos")
                return false
            }
            
            if !esCorreoValido(email) {
                mostrarAlerta(titulo: "Correo inválido", mensaje: "Ingresa un correo electrónico válido.")
                return false
            }
            
            usuario.nombre = nombre
            usuario.apellidos = apellidos
            usuario.email = email
            
            return true
        }
        return true
    }
    
    @IBAction func volverLogin(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func siguiente(_ sender: UIButton) {
        view.endEditing(true)
    }
    
    
    func agregarPaddingIzquierdo(_ textField: UITextField) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    func esCorreoValido(_ correo: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: correo)
    }
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        guard presentedViewController == nil else {
            // Si ya hay un ViewController presentado, no mostrar otra alerta
            return
        }
        
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alerta, animated: true)
    }
    
}

