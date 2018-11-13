//
//  Models.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/05.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation

struct LatLong : Decodable {
    let lat: Double
    let long: Double
}

struct Coordinates : Decodable {
    let from: LatLong
    let to: LatLong
}

class Connection : Decodable {
    let from: String
    let to: String
    let coordinates: Coordinates
    let price: Double
    init(swap: Connection) {
        to = swap.from
        from = swap.to
        coordinates = Coordinates(from: swap.coordinates.to, to: swap.coordinates.from)
        price = swap.price
    }
}

struct Result : Decodable {
    let connections: [Connection]
}

extension Connection: Hashable {
    open var hashValue: Int {
        return description.hashValue
    }
}

extension Connection: Equatable {
    public static func == (lhs: Connection, rhs: Connection) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension Connection: CustomStringConvertible {
    var description: String {
        return "\(from)|\(to)"
    }
}

class ConnectionMemo {
    let id: String
    let holder: Connection?
    init(_ id: String, _ `for`: Connection? = nil, _ swap: Bool = false) {
        self.id = id
        self.holder = swap ? Connection(swap:`for`!) : `for`
    }
}

extension ConnectionMemo: Hashable {
    open var hashValue: Int {
        return description.hashValue
    }
}

extension ConnectionMemo: Equatable {
    public static func == (lhs: ConnectionMemo, rhs: ConnectionMemo) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension ConnectionMemo: CustomStringConvertible {
    var description: String {
        return id
    }
}

