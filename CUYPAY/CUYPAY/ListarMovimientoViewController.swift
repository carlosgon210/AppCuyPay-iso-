//
//  ListarMovimientoViewController.swift
//  CUYPAY
//
//  Created by DAMII on 28/04/25.
//

import UIKit
import CoreData

class ListarMovimientoViewController: UIViewController {
    
    @IBOutlet weak var fechaDatePicker: UIDatePicker!
    @IBOutlet weak var movimientoTable: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var movimmiento:[Movimiento] = [ ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        movimientoTable.dataSource = self
        movimientoTable.delegate = self
        listarMovimento()
    }
    
    
    
    @IBAction func datePickerCambio(_ sender: UIDatePicker) {
        
        listarMovimento()
        
    }
    
    @IBAction func volverBotton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func obtenerId() -> Int16{
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<user> = user.fetchRequest()
        do {
            let usuarios = try contexto.fetch(fetchRequest)
            if let usuario = usuarios.first {
                return usuario.id
            }
        } catch {
            print("Error al obtener el usuario: \(error.localizedDescription)")
        }
        
        return 0
    }
    
    
    func listarMovimento(){
        let baseURL="http://cuypayapi-env.eba-mwhcscrk.us-east-1.elasticbeanstalk.com"
        
        let movimientoURL="/api/movimiento"
        
        let peticionCalcularBalance="/listar"//GET
        
        let id = obtenerId()
        print("funcion obtenerIdGuardado() = \(id)")
        let mesActual = Calendar.current.component(.month, from: fechaDatePicker.date)
        let anioActual = Calendar.current.component(.year, from: fechaDatePicker.date)
        let urlPeticion=URL(string:baseURL+movimientoURL+peticionCalcularBalance+"?id=\(id)&mes=\(mesActual)&anio=\(anioActual)")
        
        
        var urlRequest = URLRequest(url:urlPeticion!)
        
        
        urlRequest.httpMethod="GET"
        
        
        let peticion=URLSession.shared.dataTask(with: urlRequest,
                                                completionHandler:{(data:Data?,
                                                                    urlResponse:URLResponse?,
                                                                    error:Error?) in
            if(error==nil){
                if(data != nil && urlResponse != nil){
                    do{
                        let json = try JSONSerialization.jsonObject(with:data!) as? [String: Any]
                        let lista = json!["ListaMovimiento"] as! [[String : Any]]
                        var movimentosCargados:[Movimiento] = []
                        for item in lista {
                            let descripcion = item["descripcion"] as? String ?? ""
                            let monto = item["monto"] as? Double ?? 0.0
                            let tipo = item["tipo"] as? String ?? ""
                            
                            let fechaString = item["fecha"] as? String ?? ""
                            let dateFormatter = ISO8601DateFormatter()
                            let fecha = dateFormatter.date(from: fechaString) ?? Date()
                            
                            let movimiento = Movimiento(monto: monto, descripcion: descripcion,fecha: fecha, tipo: tipo)
                            movimentosCargados.append(movimiento)
                            
                        }
                        
                        DispatchQueue.main.async {
                            self.movimmiento = movimentosCargados
                            self.movimientoTable.reloadData()
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


extension ListarMovimientoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movimmiento.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "moviminetoCelda", for: indexPath) as! MovimentoTableViewCell
        let movimmiento = movimmiento[indexPath.row]
        celda.descripcionLable.text = movimmiento.descripcion
        celda.montoLable.text = String(movimmiento.monto)

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        celda.fechaLable.text = dateFormatter.string(from: movimmiento.fecha)

        if movimmiento.tipo == "ingreso" {
            celda.contentView.backgroundColor = UIColor(red: 0.7, green: 1.0, blue: 0.7, alpha: 1.0)
        } else {
            celda.contentView.backgroundColor = UIColor(red: 1.0, green: 0.7, blue: 0.7, alpha: 1.0)
        }
        

        return celda
    }
}








extension ListarMovimientoViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            movimmiento.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
