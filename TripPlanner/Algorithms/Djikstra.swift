//
//  Djikstra.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/07.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation

/// NOTE: Never got around to to applying this faster strategy for large datasets

open class Node {
    
    open var identifier: String                     /// Unique node hashing
    open var neighbors: [(Node, Double)] = []       /// Proximity node and weight
    open var pathLengthFromStart = Double.infinity  /// Relaxed calculated value
    open var pathVerticesFromStart: [Node] = []     /// Each node on the path
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    open func clearCache() {
        pathLengthFromStart = Double.infinity
        pathVerticesFromStart = []
    }
    
}

extension Node: Hashable {
    open var hashValue: Int {
        return identifier.hashValue
    }
}

extension Node: Equatable {
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

public class Dijkstra {
    
    private var totalVertices: Set<Node> /// Store all nodes in the graph
    
    public init(vertices: Set<Node>) {
        totalVertices = vertices
    }
    
    private func clearCache() {
        totalVertices.forEach { $0.clearCache() }
    }
    
    public func findShortestPaths(from startVertex: Node) {
        clearCache() /// Each node has a reference between a class node
        var totalVerticesSet = self.totalVertices
        startVertex.pathLengthFromStart = 0
        startVertex.pathVerticesFromStart.append(startVertex)
        var currentVertex: Node? = startVertex
        while let vertex = currentVertex { /// As long as the options are not nil, it will go through
            /// Set node access status Use unvisited nodes Delete delegates have visited  if !vertex.visited then
            totalVerticesSet.remove(vertex) /// Delete visited nodes
            let filteredNeighbors = vertex.neighbors.filter { totalVerticesSet.contains($0.0) } ///neighbors: [(Vertex, Double)] Whether the current node contains a temporary node true filter out
            for neighbor in filteredNeighbors { /// Take all neighboring nodes for relaxation calculation and compare them (if the current node to the starting distance + weight < neighboring nodes then update the neighboring nodes)
                let neighborVertex = neighbor.0
                let weight = neighbor.1
                let theoreticNewWeight = vertex.pathLengthFromStart + weight
                if theoreticNewWeight < neighborVertex.pathLengthFromStart { /// If the value after relaxation < Distance from the starting point to the point Update
                    neighborVertex.pathLengthFromStart = theoreticNewWeight
                    neighborVertex.pathVerticesFromStart = vertex.pathVerticesFromStart /// Add the current pathVerticesFromStart to the empty array of adjacent nodes. Append
                    neighborVertex.pathVerticesFromStart.append(neighborVertex)
                }
            }
            if totalVerticesSet.isEmpty { /// Option to nil stop
                currentVertex = nil
                break
            } /// Delete a vertex and reassign currentVertex. The value is the smallest in the set. Judging from the value from the starting point to the current node.
            currentVertex = totalVerticesSet.min { $0.pathLengthFromStart < $1.pathLengthFromStart }
        }
    }
    
}

class Test {
    
    var vertices: Set<Node> = Set()
    
    func createNotConnectedVertices() {
        //change this value to increase or decrease amount of vertices in the graph
        let numberOfVerticesInGraph = 15
        for idx in 0..<numberOfVerticesInGraph {
            let vertex = Node(identifier: "\(idx)")
            vertices.insert(vertex)
        }
    }
    
    func setupConnections() {
        for vertex in vertices {
            //the amount of edges each vertex can have
            let randomEdgesCount = arc4random_uniform(4) + 1
            for _ in 0..<randomEdgesCount {
                //randomize weight value from 0 to 9
                let randomWeight = Double(arc4random_uniform(10))
                let neighborVertex = randomVertex(except: vertex) /// Get neighboring nodes
                //we need this check to set only one connection between two equal pairs of vertices
                if vertex.neighbors.contains(where: { $0.0 == neighborVertex }) { /// Skip if the same node exists
                    continue
                }
                //creating neighbors and setting them
                let neighbor1 = (neighborVertex, randomWeight)
                let neighbor2 = (vertex, randomWeight)
                vertex.neighbors.append(neighbor1)
                neighborVertex.neighbors.append(neighbor2)
            }
        }
    }
    
    func randomVertex(except vertex: Node) -> Node {
        var newSet = vertices
        newSet.remove(vertex) /// If the same node is deleted
        let offset = Int(arc4random_uniform(UInt32(newSet.count)))
        let index = newSet.index(newSet.startIndex, offsetBy: offset)
        return newSet[index]
    }
    
    func randomVertex() -> Node {
        let offset = Int(arc4random_uniform(UInt32(vertices.count)))
        let index = vertices.index(vertices.startIndex, offsetBy: offset)
        return vertices[index]
    }

    func main() {
        
        //initialize random graph
        createNotConnectedVertices()
        setupConnections()
        
        //initialize Dijkstra algorithm with graph vertices
        let dijkstra = Dijkstra(vertices: vertices)
        
        //decide which vertex will be the starting one
        let startVertex = randomVertex()
        
        let startTime = Date()
        
        //ask algorithm to find shortest paths from start vertex to all others
        dijkstra.findShortestPaths(from: startVertex)
        
        let endTime = Date()
        
        print("calculation time is = \((endTime.timeIntervalSince(startTime))) sec")
        
        //printing results
        let destinationVertex = randomVertex(except: startVertex)
        print(destinationVertex.pathLengthFromStart)
        var pathVerticesFromStartString: [String] = []
        for vertex in destinationVertex.pathVerticesFromStart {
            pathVerticesFromStartString.append(vertex.identifier)
        }
        
        print(pathVerticesFromStartString.joined(separator: "->"))
        
        print(vertices.first?.identifier ?? "👀" )
        
    }
    
}
