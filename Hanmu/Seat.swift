//
//  Seat.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/15.
//

import Foundation
/**
 "local" : false,
 "computer" : false,
 "id" : 12022,
 "power" : true,
 "type" : "seat",
 "status" : "FREE",
 "name" : "054",
 "window" : false
 */

class Seat {
    var id: Int
    var name: String
    var isPower: Bool
    var isWindow: Bool
    var isComputer: Bool
    var isFree: Bool
    
    init(id: Int, name: String, isPower: Bool, isWindow: Bool, isComputer: Bool, isFree: Bool){
        self.id = id
        self.name = name
        self.isPower = isPower
        self.isWindow = isWindow
        self.isFree = isFree
        self.isComputer = isComputer
    }
}
