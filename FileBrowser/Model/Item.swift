//
//  Item.swift
//  FileBrowser
//
//  Created by Дмитро  on 20.06.2022.
//

import Foundation

enum ItemType {
   case f,d
}

class Item {
    var name: String
    var uuid: UUID?
    var type: ItemType

    var parentUUID: UUID?
    
    init(name: String, uuid: UUID? = nil, parentUUID: UUID? = nil , type: ItemType) {
        self.name = name
        self.uuid = uuid
        self.type = type
        self.parentUUID = parentUUID
    }
}
