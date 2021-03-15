//
//  Building.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/15.
//

import Foundation
class Building {
    var id: Int
    var name: String
    var rooms: Dictionary<Int, Room> = [:]
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
