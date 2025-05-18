//
//  CalcularMovimientoViewController.swift
//  CUYPAY
//
//  Created by DAMII on 28/04/25.
//

import UIKit
import CoreData

class CalcularMovimientoViewController: UIViewController {
    
    @IBOutlet weak var montoLable: UILabel!
    
    @IBOutlet weak var gastoLable: UILabel!
    
    @IBOutlet weak var ingresoLable: UILabel!
    
    let mesActual = Int(Calendar.current.component(.month, from: Date()))
    let anioActual = Int(Calendar.current.component(.year, from: Date()))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enviarPeticionBalanza()
        enviarPeticionIngreso()
        enviarPeticionGasto()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Llamar a las funciones para cargar los datos cada vez que la vista aparece
        enviarPeticionBalanza()
        enviarPeticionIngreso()
        enviarPeticionGasto()
    }
    
    //funcion para obtener id de CoreData
    func obtenerId() -> Int16{
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<user> = user.fetchRequest()
        
        do {
            let usuarios = try contexto.fetch(fetchRequest)
            print(usuarios)
            if let usuario = usuarios.first {
                return usuario.id
            }
        } catch {
            print("Error al obtener el usuario: \(error.localizedDescription)")
        }
        
        return 0
    }
    
    @IBAction func cerrarBotton(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Cerrar Sesión", message: "¿Deseas cerrar sesión?", preferredStyle: .alert
        )
        
        let cerrarAction = UIAlertAction(title: "Sí", style: .destructive) { _ in
            let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<user> = user.fetchRequest()
            do {
                let usuarios = try contexto.fetch(fetchRequest)
                for usuario in usuarios {
                    contexto.delete(usuario)
                }
                try contexto.save()
                print("Usuario eliminado de CoreData al cerrar sesión")
            } catch {
                print("Error al eliminar usuario de CoreData: \(error.localizedDescription)")
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alertController.addAction(cerrarAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func enviarPeticionGasto(){
        let baseURL="http://cuypayapi-env.eba-mwhcscrk.us-east-1.elasticbeanstalk.com"
        let movimientoURL="/api/movimiento"
        let peticionCalcularBalance="/gasto"
        let id = obtenerId()
        let urlPeticion=URL(string:baseURL+movimientoURL+peticionCalcularBalance+"?id=\(id)&mes=\(mesActual)&anio=\(anioActual)")
        
        //Crear elemento peticion/request
        var urlRequest = URLRequest(url:urlPeticion!)
        
        //definir metodo
        urlRequest.httpMethod="GET"
        
        //Crear Consulta
        let peticion=URLSession.shared.dataTask(with: urlRequest,
                                                completionHandler:{(data:Data?,
                                                                    urlResponse:URLResponse?,
                                                                    error:Error?) in
            
            if(error==nil){
                //no hay errors
                if(data != nil && urlResponse != nil){
                    
                    //Procesar datos
                    do{
                        let json = try JSONSerialization.jsonObject(with:data!) as? [String: Any]
                        if let campo = json?["GastoMensual"] as? Double {
                            print("GastoMensual: \(campo)")
                            DispatchQueue.main.async {
                                self.gastoLable.text = "Gasto mensual: \(String(format: "%.2f", campo))"
                            }
                        } else {
                            print("GastoMensual no encontrado o inválido")
                            DispatchQueue.main.async {
                                self.gastoLable.text = "0.00"
                            }
                        }
                    }catch{
                        print(error.localizedDescription)
                    }
                }else{
                    print("Data es vacia o urlResponse es vacio")
                }
            }else{
                print(error?.localizedDescription as Any)
            }
        })
        peticion.resume()
    }
    
    func enviarPeticionIngreso(){
        let baseURL="http://cuypayapi-env.eba-mwhcscrk.us-east-1.elasticbeanstalk.com"
        let movimientoURL="/api/movimiento"
        let peticionCalcularBalance="/ingreso"
        let id = obtenerId()
        let urlPeticion=URL(string:baseURL+movimientoURL+peticionCalcularBalance+"?id=\(id)&mes=\(mesActual)&anio=\(anioActual)")
        
        //Crear elemento peticion/request
        var urlRequest = URLRequest(url:urlPeticion!)
        
        //definir metodo
        urlRequest.httpMethod="GET"
        
        //Crear Consulta
        let peticion=URLSession.shared.dataTask(with: urlRequest,
                                                completionHandler:{(data:Data?,
                                                                    urlResponse:URLResponse?,
                                                                    error:Error?) in
            
            if(error==nil){
                //no hay errors
                if(data != nil && urlResponse != nil){
                    //Procesar datos
                    do{
                        let json = try JSONSerialization.jsonObject(with:data!) as? [String: Any]
                        if let campo = json?["IngresoMensual"] as? Double {
                            print("IngresoMensual: \(campo)")
                            DispatchQueue.main.async {
                                self.ingresoLable.text = "Ingreso mensual: \(String(format: "%.2f", campo))"
                            }
                        } else {
                            print("IngresoMensual no encontrado o inválido")
                            DispatchQueue.main.async {
                                self.ingresoLable.text = "0.00"
                            }
                        }
                    }catch{
                        print(error.localizedDescription)
                    }
                }else{
                    print("Data es vacia o urlResponse es vacio")
                }
            }else{
                print(error?.localizedDescription as Any)
            }
        })
        //ejecuta consulta
        peticion.resume()
    }
    
    func enviarPeticionBalanza(){
        let baseURL="http://cuypayapi-env.eba-mwhcscrk.us-east-1.elasticbeanstalk.com"
        let movimientoURL="/api/movimiento"
        let peticionCalcularBalance="/balance"//GET
        let id = obtenerId()
        print("id en enviar peticion balanza \(id)")
        let urlPeticion=URL(string:baseURL+movimientoURL+peticionCalcularBalance+"?id=\(id)&mes=\(mesActual)&anio=\(anioActual)")
        
        //Crear elemento peticion/request
        
        var urlRequest = URLRequest(url:urlPeticion!)
        
        //definir metodo
        
        urlRequest.httpMethod="GET"
        
        //Crear Consulta
        
        let peticion=URLSession.shared.dataTask(with: urlRequest,
                                                completionHandler:{(data:Data?,
                                                                    urlResponse:URLResponse?,
                                                                    error:Error?) in
            
            if(error==nil){
                //no hay errors
                if(data != nil && urlResponse != nil){
                    //Procesar datos
                    do{
                        let json = try JSONSerialization.jsonObject(with:data!) as? [String: Any]
                        if let campo = json?["BalanceMensual"] as? Double {
                            print("BalanceMensual: \(campo)")
                            DispatchQueue.main.async {
                                self.montoLable.text = String(format: "%.2f", campo)
                            }
                        } else {
                            print("BalanceMensual no encontrado o inválido")
                            DispatchQueue.main.async {
                                self.montoLable.text = "0.00"
                            }
                        }
                        
                    }catch{
                        print(error.localizedDescription)
                    }
                }else{
                    print("Data es vacia o urlResponse es vacio")
                }
            }else{
                print(error?.localizedDescription as Any)
            }
        })
        peticion.resume()
    }
    
}
