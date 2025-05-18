//
//  registrarSegundaParteViewController.swift
//  CUYPAY
//
//  Created by KAWORU on 29/04/25.
//

import UIKit

class registrarSegundaParteViewController: UIViewController {
    
    var usuario: Usuario!
    
    
    @IBOutlet weak var usuarioText: UITextField!
    
    @IBOutlet weak var clave1Text: UITextField!
    
    @IBOutlet weak var clave2Text: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.endEditing(true)
        
        agregarPaddingIzquierdo(usuarioText)
        agregarPaddingIzquierdo(clave1Text)
        agregarPaddingIzquierdo(clave1Text)
        agregarPaddingIzquierdo(clave2Text)
        
        clave1Text.isSecureTextEntry = true
        clave2Text.isSecureTextEntry = true
        
        // Confirmar que los datos llegaron
        print("Datos recibidos desde la primera vista:")
        print("Nombre: \(usuario.nombre)")
        print("Apellidos: \(usuario.apellidos)")
        print("Email: \(usuario.email)")
    }
    
    
    func agregarPaddingIzquierdo(_ textField: UITextField) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    @IBAction func confirmarRegistro(_ sender: UIButton) {
        guard
            let usuarioTexto = usuarioText.text,
            let clave1 = clave1Text.text,
            let clave2 = clave2Text.text,
            !usuarioTexto.isEmpty, !clave1.isEmpty, !clave2.isEmpty
        else {
            mostrarAlerta(titulo: "Error", mensaje: "Completa todos los campos")
            return
        }
        
        if clave1 != clave2 {
            mostrarAlerta(titulo: "Error", mensaje: "Las contraseñas no coinciden")
            return
        }
        
        usuario.usuario = usuarioTexto
        usuario.clave1 = clave1
        usuario.clave2 = clave2
        
        // DEBUG: Mostrar todos los datos antes de enviar
        print("Datos enviados a la API:")
        print("Nombre: \(usuario.nombre)")
        print("Apellidos: \(usuario.apellidos)")
        print("Email: \(usuario.email)")
        print("Usuario: \(usuario.usuario)")
        print("Clave1: \(usuario.clave1)")
        print("Clave2: \(usuario.clave2)")
        
        registrarUsuario(usuario)
        
    }
    
    
    
    @IBAction func cancelarRegistro(_ sender: UIButton) {
        
        let alerta = UIAlertController(
            title: "¿Cancelar registro?",
            message: "Se perderán los datos ingresados. ¿Deseas continuar?",
            preferredStyle: .alert
        )
        
        let accionSi = UIAlertAction(title: "Sí", style: .destructive) { _ in
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        
        let accionNo = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alerta.addAction(accionSi)
        alerta.addAction(accionNo)
        
        self.present(alerta, animated: true, completion: nil)
    }
    
    
    
    func registrarUsuario(_ usuario: Usuario) {
        
        let urlString =
        "http://cuypayapi-env.eba-mwhcscrk.us-east-1.elasticbeanstalk.com/api/usuario/registrar"
        guard let url = URL(string: urlString) else {
            print("URL invalida")
            return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let body: [String: Any] = [
            
            "nombre": usuario.nombre,
            "apellidos": usuario.apellidos,
            "usuario": usuarioText.text ?? "",
            "email": usuario.email,
            "clave1": clave1Text.text ?? "",
            "clave2": clave2Text.text ?? ""
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            
            print("Error al crear el cuerpo de la solicitud")
            
            return
        }
        
        if let bodyDataString = String(data: httpBody, encoding: .utf8) {
            print("Cuerpo enviado: \(bodyDataString)")
        }
        
        
        do {
            let jsonData = try JSONEncoder().encode(usuario)
            request.httpBody = jsonData
        } catch {
            print("Error al codificar datos del usuario:\(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error al registrar: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Respuesta no válida del servidor.")
                return
            }
            
            DispatchQueue.main.async {
                if httpResponse.statusCode == 200 {
                    self.mostrarAlerta(titulo: "Éxito", mensaje: "Registro exitoso")
                } else {
                    self.mostrarAlerta(titulo: "Error", mensaje: "Error del servidor (\(httpResponse.statusCode))")
                }
            }
        }
        
        task.resume()
    }
    
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default)
                        { _ in
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        })
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
