//
//  Models.swift
//  droptheball
//

import Foundation

struct Player: Identifiable, Codable, Equatable {
    let id: Int
    var name: String
    var isPresent: Bool
    var arriveTime: String
    var departTime: String
    var playCount: Int
    var satOutLast: Bool
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
}

struct Court: Codable {
    var team1: [Int]
    var team2: [Int]
}

struct TimeSlot: Identifiable, Codable {
    let id: Int
    let time: String
    var courts: [Court]?
    var sitters: [Int]?
}
