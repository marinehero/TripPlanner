//
//  Strategy.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/05.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation

struct Strategy {
    
    static public func findClosest(using: String, latlong: LatLong, data: Result) -> LatLong {
        
        for e in data.connections {
            if e.from == using && e.coordinates.from.valid {
                return e.coordinates.from
            }
            if e.to == using && e.coordinates.to.valid {
                return e.coordinates.to
            }
        }
        return latlong
    }
    
    static public func validateAndFix(_ data: Result) -> Bool {

        var autoFixed = false
        
        for e in data.connections {
            if !e.coordinates.from.valid {
                let latlong = findClosest(using: e.from, latlong:e.coordinates.from, data: data)
                e.coordinates.from = latlong
                autoFixed = true
            }
            if !e.coordinates.to.valid {
                let latlong = findClosest(using: e.to, latlong:e.coordinates.to, data: data)
                e.coordinates.to = latlong
                autoFixed = true
            }
        }
        return autoFixed
    }
    
    static public func calculateCheapestFlight(from: String, dest: String, data: Result)
        -> (total: Double, schedule: Schedule, fromData: AutoCompleteDataSource, destData: AutoCompleteDataSource) {
        
        if validateAndFix(data) {
            print("Invalid coordinate data has been changed...")
        }
        
        var graph = AdjacencyMatrixGraph<ConnectionMemo>()
        
        print()
        
        data.connections.forEach {
            
            let frNode = graph.createVertex(ConnectionMemo($0.from, $0))
            let toNode = graph.createVertex(ConnectionMemo($0.to, $0, true))
            graph.addDirectEdge(lhs: frNode, rhs: toNode, weight: $0.price)
            graph.addDirectEdge(lhs: toNode, rhs: frNode, weight: $0.price)
            print("\($0) \t\t\tF: \($0.from) T: \($0.to) Price: \($0.price)")
            
        }
        
        print()
        
        let fromNode = graph.createVertex(ConnectionMemo( from ))
        let destNode = graph.createVertex(ConnectionMemo( dest ))
        let bellManResult = graph.apply(source: fromNode)
        let vertexArray = bellManResult?.recursePathTo(vertex: destNode, graph: graph)
        
        var schedule = Schedule()
        
        var routePoints: [LatLong] = []
        
        var cost: Double = 0
        vertexArray?.forEach {
            guard let flight = $0.data.holder else { return }
            cost += flight.price
            routePoints.append(flight.coordinates.from)
            print("\($0.data) - \(flight.price) @ \(flight.coordinates.from)")
        }
        print()
        
        if  routePoints.count % 2 > 0 {
            routePoints.append((vertexArray?.last?.data.holder?.coordinates.from)!)
        }
        for idx in stride(from: 0, to: routePoints.count-1, by: 1) {
            let departure = Departure(routePoints[idx])
            let arrival = Departure(routePoints[idx+1])
            let flight = Flight(arrival: arrival, departure: departure )
            schedule.flights?.append( flight )
        }
        
        let total = bellManResult?.distance(vertexTo: destNode) ?? 0.0
        print( "cheapest = \(total) ( total = \(cost) savings = \(cost-total) )")
        
        let fromData = graph.vertices.compactMap { node in node.data.id }
        let destData = graph.vertices.compactMap { node in node.data.id }

        return ( total, schedule, Loader.load(from: fromData), Loader.load(from:destData) )
            
    }

    static public func test() {
        
        var graph = AdjacencyMatrixGraph<String>()
        let vertexA = graph.createVertex("A")
        let vertexB = graph.createVertex("B")
        let vertexC = graph.createVertex("C")
        let vertexD = graph.createVertex("D")
        let vertexE = graph.createVertex("E")
        ///       2
        graph.addDirectEdge(lhs: vertexA, rhs: vertexB, weight: 2)  ///   A ----- B
        graph.addDirectEdge(lhs: vertexB, rhs: vertexC, weight: 1)  ///   |       |  1
        graph.addDirectEdge(lhs: vertexA, rhs: vertexC, weight: 5.5)  ///   5------ C
        graph.addDirectEdge(lhs: vertexA, rhs: vertexD, weight: 1)  ///           D
        graph.addDirectEdge(lhs: vertexC, rhs: vertexD, weight: 1)  ///           D
        graph.addDirectEdge(lhs: vertexD, rhs: vertexE, weight: 4.5)  ///           E
        
        let bellManResult = graph.apply(source: vertexA)
        //let vertexArray = bellManResult?.recursePathTo(vertex: vertexC, graph: graph)
        //vertexArray?.forEach { print($0.data) } //A B C
        print(bellManResult?.distance(vertexTo: vertexE) ?? 0.0 )
        

    }
    

    static public func getTrips(using api: IGetTrips, _ onDataAvailable: @escaping (_ result: Result?, _ error: Error? ) -> Void ) {
        
        api.getTrips { result, error in
            onDataAvailable(result,error)
        }
        
    }
    
}
