//
//  UserDefaultsHelpers.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 13/05/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    enum UserDefaultsKeys: String {
        case isLoggedIn
    }
    
    
    func isLoggedIn() -> Bool {
        guard let _ = self.string(forKey: "username"), let _ = self.string(forKey: "password") else { return false }
        return true
    }
    
}
