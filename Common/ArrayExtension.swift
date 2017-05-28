//
//  ArrayExtension.swift
//  NUTManager
//
//  Created by Ricardo Chavarria on 5/28/17.
//  Copyright © 2017 Ricardo Chavarria. All rights reserved.
//

import Foundation

extension Array {
    func all(completion: (Element)->(Bool)) -> Bool {
        
        var result = true
        self.forEach { result = completion($0) }
        
        return result
    }
}
