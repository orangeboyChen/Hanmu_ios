//
//  LibraryService.swift
//  Hanmu
//
//  Created by orangeboy on 2021/6/19.
//

import Foundation

class LibraryService {
    private static var instance  = LibraryService()
    
    private init(){}
    
    public static func getInstance() -> LibraryService {
        return .instance
    }
    
    
}
