//
//  REST.swift
//  Carangas
//
//  Created by Usuário Convidado on 13/03/19.
//  Copyright © 2019 Eric Brito. All rights reserved.
//

import Foundation

class REST {
    private static let basePath = "https://carangas.herokuapp.com/cars"
    
    
    //private static let session = URLSession.shared
    private static let configuration: URLSessionConfiguration = {
       
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = false
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        config.timeoutIntervalForRequest = 30.0
        config.httpMaximumConnectionsPerHost = 3
        return config
    }()
    
    private static let session = URLSession(configuration: configuration)
    
    class func loadCars(onComplete: @escaping ([Car])->Void) {
        guard let url: URL = URL(string: basePath)else{
            print("Erro ao montar URL")
            return
        }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("Deu erro: ", error!)
                return
            }
            
            guard let response = response as? HTTPURLResponse else{
                print("Response Nulo")
                return
            }
            
            if response.statusCode != 200 {
                print("Erro de status code: ", response.statusCode)
                return
            }
            
            guard let data = data else{
                print("Dados inválidos")
                return
            }
            do{
                let cars = try JSONDecoder().decode([Car].self, from: data)
                print("Total de Carros: ", cars.count)
                onComplete(cars)
                
            }catch{
                print("Erro ao tratar JSON")
            }
        }
        
        task.resume()
        
    }
    
    class func applyOperation(_ operation: RESTOperation, car: Car, onComplete: @escaping (Bool)->Void){
        let urlString = basePath + "/" + (car._id ?? "")
        var httpMethod: String = ""
        switch operation {
        case .delete:
            httpMethod = "DELETE"
        case .save:
            httpMethod = "POST"
        case .update:
            httpMethod = "PUT"
            
            guard let url = URL(string: urlString) else{
                onComplete(false)
                return
            }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = httpMethod
            urlRequest.httpBody = try! JSONEncoder().encode(car) //modo vagabundo, tem que fazer o do e o catch
            
            
            let task = session.dataTask(with: urlRequest) { (data, _, _) in // os _ foram colocados só pra não ter que fazer tudo de novo
                guard let _ = data else{
                    onComplete(false)
                    return
                }
                onComplete(true)
                
            }
            task.resume()
        }
    }
    
}

enum RESTOperation {
    case update
    case delete
    case save
}
