//
//  Server.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

public func getRequestWithAuth(_ url: String) -> URLRequest{
    let endpointUrl = URL(string: SERVER + url)! // whatever is your url
    let username = "a"
    let password = "a"
    let loginString = String(format: "%@:%@", username, password)
    let loginData = loginString.data(using: String.Encoding.utf8)!
    let base64LoginString = loginData.base64EncodedString() // whatever is your token
    var request = URLRequest(url: endpointUrl)
    
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    return request
}

