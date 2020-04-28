//
//  Server.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 23/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import Foundation
import UIKit

public func getBase64LoginString() -> String{
    let defaults = UserDefaults.standard
    guard let username = defaults.string(forKey: "username"), let password = defaults.string(forKey: "password") else { return "" }
    let loginString = String(format: "%@:%@", username, password)
    let loginData = loginString.data(using: String.Encoding.utf8)!
    let base64LoginString = loginData.base64EncodedString()
    return base64LoginString
}

public func getRequestWithAuth(_ url: String) -> URLRequest{
    let endpointUrl = URL(string: SERVER + url)! // whatever is your url
    var request = URLRequest(url: endpointUrl)
    
    request.setValue("Basic \(getBase64LoginString())", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    return request
}


class Server {
    
    static func get(_ urlString: String, finish: @escaping (Data?) -> Void, error: @escaping (Data?) -> Void){
        retrieve(urlString, method: "GET", finish: finish, errorFunction: error)
    }
    static func retrieve(_ urlString: String, method: String, finish: @escaping (Data?) -> Void, errorFunction: @escaping (Data?) -> Void){
        var request = getRequestWithAuth(urlString)
        request.httpMethod = method
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                finish(data)
            } else {
                errorFunction(data)
            }
        })
        task.resume()
    }
    static func post(_ urlString: String, json: [String:Any?], finish: @escaping (Data?) -> Void, error: @escaping (Data?) -> Void){
        update(urlString, json: json, method: "POST", finish: finish, errorFunction: error)
    }
    static func patch(_ urlString: String, json: [String:Any?], finish: @escaping (Data?) -> Void, error: @escaping (Data?) -> Void){
        update(urlString, json: json, method: "PATCH", finish: finish, errorFunction: error)
    }
    
    static func update(_ urlString: String, json: [String:Any?], method: String, finish: @escaping (Data?) -> Void, errorFunction: @escaping (Data?) -> Void){
        var request = getRequestWithAuth(urlString)
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpMethod = method
            request.httpBody = data
            let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error -> Void in
                if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                    finish(data)
                } else {
                    errorFunction(data)
                }
            })
            task.resume()
        }catch{
            //
        }
    }
}
