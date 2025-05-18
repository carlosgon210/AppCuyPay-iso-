//
//  InsertarMovimientoViewController.swift
//  CUYPAY
//
//  Created by DAMII on 3/05/25.
//

import UIKit
import CoreData

class InsertarMovimientoViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var montoText: UITextField!
    @IBOutlet weak var descripText: UIButton!
    @IBOutlet weak var tipoText: UIButton!
    
    
    let opcionesIngreso = ["Pago mes", "Transferencia", "Pago amigo"]
    let opcionesGasto = ["Comida", "Salud", "Tienda"]
    
    var opcionSeleccionadaTipo: String = "Ingreso"
    var opcionSeleccionadaDescripcion: String = "Pago mes"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        montoText.delegate = self
        
        descripText.isEnabled = false
        descripText.setTitle("Selecciona tipo primero", for: .normal)
        
        agregarPaddingIzquierdo(montoText)
        
        configurarMenus()
        
    }
    
    
    @IBAction func insertarBotton(_ sender: Any) {
        ingresarMovimiento()
    }
    
    @IBAction func volverBotton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func configurarMenus() {
        let tipoMenu = UIMenu(title: "Selecciona tipo", children: ["Ingreso", "Gasto"].map { tipo in
            UIAction(title: tipo, handler: { [weak self] _ in
                self?.tipoText.setTitle(tipo, for: .normal)
                self?.opcionSeleccionadaTipo = tipo
                self?.descripText.isEnabled = true
                self?.actualizarMenuDescripcion(segun: tipo)
                
                // Llamar a la función para cambiar el color de fondo del botón
                self?.actualizarColorFondoTipo()
            })
        })
        tipoText.menu = tipoMenu
        tipoText.showsMenuAsPrimaryAction = true
        
        descripText.isEnabled = false
        descripText.setTitle("Selecciona tipo primero", for: .normal)
    }
    
    private func actualizarMenuDescripcion(segun tipo: String) {
        let opciones = tipo == "Ingreso" ? opcionesIngreso : opcionesGasto
        
        let descripMenu = UIMenu(title: "Selecciona descripción", children: opciones.map { desc in
            UIAction(title: desc, handler: { [weak self] _ in
                self?.descripText.setTitle(desc, for: .normal)
                self?.opcionSeleccionadaDescripcion = desc
            })
        })
        
        descripText.menu = descripMenu
        descripText.setTitle("Selecciona descripción", for: .normal)
        descripText.showsMenuAsPrimaryAction = true
        
        opcionSeleccionadaDescripcion = ""
    }
    
    private func actualizarColorFondoTipo() {
        if opcionSeleccionadaTipo == "Ingreso" {
            tipoText.backgroundColor = UIColor.green.withAlphaComponent(0.3)
            tipoText.setTitleColor(.black, for: .normal)
        } else if opcionSeleccionadaTipo == "Gasto" {
            tipoText.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            tipoText.setTitleColor(.white, for: .normal)
        } else {
            tipoText.backgroundColor = .clear
            tipoText.setTitleColor(.black, for: .normal)
        }
    }

    
    func obtenerId() -> Int16 {
        let fetchRequest: NSFetchRequest<user> = user.fetchRequest()
        do {
            let usuarios = try context.fetch(fetchRequest)
            if let usuario = usuarios.first {
                return usuario.id
            }
        } catch {
            print("Error al obtener el usuario: \(error.localizedDescription)")
        }
        return 0
    }
    
    private func ingresarMovimiento() {
        guard let montoTexto = montoText.text, !montoTexto.isEmpty else {
            mostrarAlerta(titulo: "Campo vacío", mensaje: "Por favor ingresa un monto.")
            return
        }
        
        let id = obtenerId()
        print("Tipo seleccionado: \(opcionSeleccionadaTipo), Descripción: \(opcionSeleccionadaDescripcion), ID: \(id)")
        
        let urlString = "http://cuypayapi-env.eba-mwhcscrk.us-east-1.elasticbeanstalk.com/api/movimiento/insertar"
        guard let url = URL(string: urlString) else {
            print("URL inválida")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "usuarioId": id,
            "monto": Double(montoTexto) ?? 0,
            "descripcion": opcionSeleccionadaDescripcion,
            "tipo": opcionSeleccionadaTipo.lowercased()
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            print("Error al crear el cuerpo de la solicitud")
            return
        }
        
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la solicitud: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Código de respuesta: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    let mensaje = self.opcionSeleccionadaTipo == "Ingreso"
                    ? "Ingreso registrado correctamente"
                    : "Gasto registrado correctamente"
                    
                    DispatchQueue.main.async {
                        self.mostrarAlerta(titulo: "Éxito", mensaje: mensaje)
                        self.limpiarCampos()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.mostrarAlerta(titulo: "Error", mensaje: "No se pudo registrar el movimiento. Intenta nuevamente.")
                    }
                }
            }
            
            if let data = data,
               let respuesta = String(data: data, encoding: .utf8) {
                print("Respuesta de la API: \(respuesta)")
            }
        }.resume()
        
    }
    
    func agregarPaddingIzquierdo(_ textField: UITextField) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == montoText else { return true }
        
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharacters.isSuperset(of: characterSet) {
            return false
        }
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let decimalParts = updatedText.components(separatedBy: ".")
        if decimalParts.count > 2 {
            return false
        }
        
        if decimalParts.count == 2 && decimalParts[1].count > 2 {
            return false
        }
        
        return true
    }
    
    func limpiarCampos() {
        montoText.text = ""
        tipoText.setTitle("Selecciona tipo", for: .normal)
        descripText.setTitle("Selecciona tipo primero", for: .normal)
        descripText.isEnabled = false
        opcionSeleccionadaTipo = ""
        opcionSeleccionadaDescripcion = ""
    }
    
    
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
