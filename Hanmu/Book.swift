//
//  Book.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/15.
//
/**
 "id": 11196044,
 "date": "2021-3-15",
 "begin": "08:00",
 "end": "08:30",
 "awayBegin": null,
 "awayEnd": null,
 "loc": "信息馆1层西区3C创客咖啡区007号",
 "stat": "RESERVE"
 */
import Foundation
class Book: ObservableObject {
    @Published var id: Int = -1
    @Published var date: String?
    @Published var begin: String?
    @Published var end: String?
    @Published var awayBegin: String?
    @Published var awayEnd: String?
    @Published var loc: String?
    @Published var stat: String?
    
    func clear() {
        id = -1
        date = nil
        begin = nil
        end = nil
        awayBegin = nil
        awayEnd = nil
        loc = nil
        stat = nil
    }
}
