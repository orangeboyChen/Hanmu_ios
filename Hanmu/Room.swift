//
//  Room.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/15.
//

import Foundation
class Room {
    var id: Int
    var buildingId: Int
    var name: String
    var floor: Int
    var free: Int = -1
    var total: Int = -1
    
    init(id: Int, buildingId: Int, name: String, floor: Int){
        self.id = id
        self.buildingId = buildingId
        self.name = name
        self.floor = floor
    }
}
