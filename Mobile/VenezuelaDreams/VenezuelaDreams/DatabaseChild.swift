//
//  DatabaseChild.swift
//  VenezuelaDreams
//
//  Created by Pascal on 3/10/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import Foundation
import UIKit

class DatabaseChild{
    var id: String?
    var name: String?
    var description: String?
    var childUrl: String?
    
    init(id:String?, name: String?, description: String?,childUrl: String?){
        self.id = id
        self.name = name
        self.description = description
        self.childUrl = childUrl
    }
    
    
}
