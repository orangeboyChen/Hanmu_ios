//
//  HanmuResult.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/17.
//

import Foundation
class HanmuResult: Hashable, Equatable {
    static func == (lhs: HanmuResult, rhs: HanmuResult) -> Bool {
        return "\(lhs.date)\(lhs.costTime)\(lhs.distance)\(lhs.speed)\(lhs.hour)" == "\(rhs.date)\(rhs.costTime)\(rhs.distance)\(rhs.speed)\(rhs.hour)"
    }

    
    var hashValue : Int {
        get {
            return "\(date)\(costTime)\(distance)\(speed)\(hour)".hashValue
        }
    }
    
    var id: Int = -1
    var date: String = ""
    var costTime: String = ""
    var distance: Double = -1
    var speed: Double = -1
    var hour: Int = -1
}

