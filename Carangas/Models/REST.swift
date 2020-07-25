//
//  REST.swift
//  Carangas
//
//  Created by Rafaela on 24/07/20.
//  Copyright © 2020 Eric Brito. All rights reserved.
//

import Foundation

enum CarError {
    case url
    case taskError(error: Error)
    case noResponse
    case noData
    case responseStatusCode(code: Int)
    case invalidJSON
}

enum RESTOperation {
    case save
    case update
    case delete
}

class REST{
    private static let basePath = "https://carangas.herokuapp.com/cars"
    private static let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = false
        config.httpAdditionalHeaders = ["Content-Type":"application/json"]
        config.timeoutIntervalForRequest = 30.0
        config.httpMaximumConnectionsPerHost = 5
        return config //para as informacoes irem para configuration e usar abaixo
    } ()
    private static let session = URLSession(configuration: configuration)
    //class func: metodo de classe, metodo executado sem precisar instanciar a classe
    
    class func loadBrands(onComplete: @escaping ([Brand]?) -> Void){
        guard let url = URL(string: "https://fipeapi.appspot.com/api/1/carros/marcas.json") else {
            onComplete(nil)
            return
        }
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                guard let response = response as? HTTPURLResponse else {
                    onComplete(nil)
                    return
                }
                if response.statusCode == 200 {
                    guard let data = data else {return}
                    do {
                        let brands = try JSONDecoder().decode([Brand].self, from: data)
                        onComplete(brands)
                    } catch {
                        onComplete(nil)
                    }
                } else {
                    onComplete(nil)                }
            } else {
                onComplete(nil)
            }
        }
        dataTask.resume() //este metodo que vai executar a tarefa
    }
    
    //GET, a api vai devolver todos os carros cadastrados
    class func loadCars(onComplete: @escaping ([Car]) -> Void, onError: @escaping (CarError) -> Void){ //(onComplete:(no final da minha requisicao) () -> Void)(crio uma clouser) criar uma closure para poder popular o array car la no CarsTableViewController
        // @escaping é para não se perder os dados por ser uma closure
        guard let url = URL(string: basePath) else { //guard let pq pode retornar nulo, se for o caso vai p closure erro
            onError(.url)
            return
        }
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            //este metodo apenas cria a tarefa e nao executa, por isso tem que atribuir ao objeto dataTask
            //este Error apresenta apenas erros do app, erros do servidos vem na response
            if error == nil {
                guard let response = response as? HTTPURLResponse else {
                    onError(.noResponse)
                    return
                }
                if response.statusCode == 200 {
                    guard let data = data else {return}
                    do {
                        let cars = try JSONDecoder().decode([Car].self, from: data)
                        onComplete(cars)
                    } catch {
                        onError(.invalidJSON)
                    }
                } else {
                    onError(.responseStatusCode(code: response.statusCode))
                }
            } else {
                onError(.taskError(error: error!))
            }
        }
        dataTask.resume() //este metodo que vai executar a tarefa
    }
    
    class func save(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: car, operation: .save, onComplete: onComplete)
    }
    
    class func update(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: car, operation: .update, onComplete: onComplete)
    }
    
    class func delete(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: car, operation: .delete, onComplete: onComplete)
    }
    
    private class func applyOperation(car: Car, operation:RESTOperation, onComplete: @escaping (Bool) -> Void) {
        
        let urlString = basePath + "/" + (car._id ?? "")
        
        guard let url = URL(string: urlString) else {
            onComplete(false)
            return
        }
        var httpMethod: String = ""
        var request = URLRequest(url: url)
        switch operation {
            case .save:
                httpMethod = "POST"
            case .update:
                httpMethod = "PUT"
            case .delete:
                httpMethod = "DELETE"
        }
        request.httpMethod = httpMethod
        //try? tenta retornar o que é pedido se nao consegue retorna nulo
        guard let json = try? JSONEncoder().encode(car) else {
            onComplete(false)
            return
        }
        request.httpBody = json
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                guard let response = response as? HTTPURLResponse, response.statusCode == 200, let _ = data else {
                    onComplete(false)
                    return
                }
                onComplete(true)
            } else {
                onComplete(false)
            }
        }
        dataTask.resume()
    }
    
}
