//
//  Server.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 23/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

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
    static func get(_ urlString: String, finish: @escaping (Data?, URLResponse?, Error?) -> Void) {
        retrieve(urlString, method: "GET", finish: finish)
    }
    static func delete(_ urlString: String, finish: @escaping (Data?, URLResponse?, Error?) -> Void) {
        retrieve(urlString, method: "DELETE", finish: finish)
    }
    static func retrieve(_ urlString: String, method: String, finish: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = getRequestWithAuth(urlString)
        request.httpMethod = method
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = TIME_OUT
        configuration.timeoutIntervalForResource = TIME_OUT
        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            finish(data, response, error)
        })

        task.resume()
    }
    static func post(_ urlString: String, json: [String:Any?], finish: @escaping (Data?, URLResponse?, Error?) -> Void){
        update(urlString, json: json, method: "POST", finish: finish)
    }
    static func put(_ urlString: String, json: [String:Any?], finish: @escaping (Data?, URLResponse?, Error?) -> Void){
        update(urlString, json: json, method: "PUT", finish: finish)
    }
    static func patch(_ urlString: String, json: [String:Any?], finish: @escaping (Data?, URLResponse?, Error?) -> Void){
        var trueJson: [String: Any] = [:]
        for k in json.keys {
            if let element = json[k] as? String, element.isEmpty {
                trueJson[k] = nil
            } else {
                trueJson[k] = json[k] as Any?
            }
        }
        update(urlString, json: trueJson, method: "PATCH", finish: finish)
    }
    static func nilPatch(_ urlString: String, json: [String:Any?], finish: @escaping (Data?, URLResponse?, Error?) -> Void){
        var trueJson: [String: Any] = [:]
        for k in json.keys {
            if let element = json[k] as? String, element.isEmpty {
                trueJson[k] = NSNull()
            } else {
                trueJson[k] = json[k] as Any?
            }
        }
        update(urlString, json: trueJson, method: "PATCH", finish: finish)
    }
    
    static func update(_ urlString: String, json: [String:Any?], method: String, finish: @escaping (Data?, URLResponse?, Error?) -> Void){
        var request = getRequestWithAuth(urlString)
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpMethod = method
            request.httpBody = data
            
            let configuration = URLSessionConfiguration.default
            configuration.waitsForConnectivity = true
            configuration.timeoutIntervalForRequest = TIME_OUT
            configuration.timeoutIntervalForResource = TIME_OUT
            let session = URLSession(configuration: configuration)
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                finish(data, response, error)
            })
            task.resume()
        }catch{
            //
        }
    }
    
    static func uploadPictures(method: HTTPMethod, urlString: String, withName: String, pictures : UIImage, finish: @escaping ((Data?)) -> Void) {
        let urll = URL(string: urlString)
        guard let url = urll else { return }
        let headers: HTTPHeaders
        headers = ["Content-type": "multipart/form-data",
                   "Content-Disposition" : "form-data",
                   "Authorization" : "Basic \(getBase64LoginString())"
        ]
        let task = AF.upload(multipartFormData: { (multipartFormData) in
            if let imageData = pictures.jpeg(.lowest) {
                multipartFormData.append(imageData, withName: withName, fileName: "IMAGE.jpg", mimeType: "image/jpg")
            }
        }, to: url, usingThreshold: UInt64.init(), method: method, headers: headers).response{ response in
            finish(response.data)
        }
    }
}
