//
//  BelmanFord.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/05.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

///        Richard Bellman . Lester Ford  1903/US
///
///        vertex A B C D E  from:A to:E
///        iteration 1 (tiems:0..<4)
///                                ordered edges       weights          result
///        -----> D .......        A-B:6               B:6              A:0
///        |              :        A-D:7               D:7              B:6
///        |              :        B-C:5               C:11             C:4 < UPDATE
///        A ---> B ----> C        B-E:-4              E:2              D:7
///               | <----          C-B:-2              B:6  NO UPDATE   E:2
///               E                D-C:-3              C:11 -> 4
///       BC determines the value of C before DC. After updating DC C-based CB needs to re-relax, the vertex changes accordingly.
///        vertex A B C D E
///        iteration 2 (tiems:0..<4)
///                                ordered edges       weights                result
///         ----> D .......        A-B:6               B:6    NO UPDATE       A:0
///        |              :        A-D:7               D:7    NO UPDATE       B:4 < UPDATE
///        |              :        B-C:5               C:4    NO UPDATE       C:4
///        A ---> B ----> C        B-E:-4              E:2    NO UPDATE       D:7
///               | <......        C-B:-2              B:6 -> 4               E:2
///               E                D-C:-3              C:4    NO UPDATE
///        vertex A B C D E
///        iteration 3 (tiems:0..<4)
///                                ordered edges       weights                       result
///         ----> D .......        A-B:6               B:4          NO UPDATE        A:0
///        |              :        A-D:7               D:7          NO UPDATE        B:4
///        |              :        B-C:5               C:4          NO UPDATE        C:4
///        A ---> B ----> C        B-E:-4              E:2 -> -2                     D:7
///               : <......        C-B:-2              B:4          NO UPDATE        E:-2 < UPDATE
///               E                D-C:-3              C:4          NO UPDATE
///        vertex A B C D E
///        iteration 4 (tiems:0..<4)
///                                ordered edges       weights                   result     UPDATE - false
///         ----> D .......        A-B:6               B:4      NO UPDATE        A:0
///        |              :        A-D:7               D:7      NO UPDATE        B:4
///        |              :        B-C:5               C:4      NO UPDATE        C:4
///        A ---> B ----> C        B-E:-4              E:2      NO UPDATE        D:7
///               : <......        C-B:-2              B:4      NO UPDATE        E:-2
///               E                D-C:-3              C:4      NO UPDATE
///
/// The advantage of Bellman-Ford over Dijkstra algorithm is that the weight of the edge can be negative.
/// The disadvantage is that the time complexity is too high, up to O(|V||E|).

// swiftlint:disable identifier_name line_length type_name


public struct Vertex<T: Hashable>: Equatable {
    var data: T
    var indexInMatrix: Int
}
public struct Edge<T: Hashable>: Equatable {
    var vertexFrom: Vertex<T>
    var vartexTo: Vertex<T>
    var weight: Double?
}
public struct AdjacencyMatrixGraph<T: Hashable>: Equatable {
    typealias ColumnVertices = [Double?]
    var matrix = [ColumnVertices]()
    var vertices = [Vertex<T>]()
}

extension AdjacencyMatrixGraph {
    var edges: [Edge<T>] {
        var temp = [Edge<T>]()
        for columnIndex in 0..<matrix.count {
            for rowIndex in 0..<matrix.count {
                if let weight = matrix[columnIndex][rowIndex] {
                    temp.append(Edge(vertexFrom: vertices[columnIndex], vartexTo: vertices[rowIndex], weight: weight))
                }
            }
        }
        return temp
    }
}

extension AdjacencyMatrixGraph {
    mutating func createVertex(_ newValue: T) -> Vertex<T> {
        let matchingVertex = vertices.filter { $0.data == newValue }
        if matchingVertex.count > 0 {
            return matchingVertex.last!
        }
        for columnIndex in 0..<matrix.count {
            matrix[columnIndex].append(nil)
        }
        let newVertex = Vertex(data: newValue, indexInMatrix: matrix.count)
        let newRow = ColumnVertices(repeating: nil, count: matrix.count + 1)
        vertices.append(newVertex)
        matrix.append(newRow)
        return newVertex
    }
}
extension AdjacencyMatrixGraph {
    mutating func addDirectEdge(lhs: Vertex<T>, rhs: Vertex<T>, weight: Double?) {
        matrix[lhs.indexInMatrix][rhs.indexInMatrix] = weight
    }
}
extension AdjacencyMatrixGraph {
    func getWeight(source: Vertex<T>, destination: Vertex<T>) -> Double? {
        return matrix[source.indexInMatrix][destination.indexInMatrix]
    }
}
/// predecessor A -> B  source = "A" indexInMatrix = 0 weight = 2  "B" indexInMatrix = 1
extension AdjacencyMatrixGraph {                                                /// 0   1   2      --->   0   1   2
    func apply(source: Vertex<T>) -> BellmanFordResult<T>? {                    /// 0   nil nil               0          vertexFromIndex
        var predecessors = [Int?](repeating: nil, count: vertices.count)        ///
        var weights = Array(repeating: Double.infinity, count: vertices.count)  /// weight               A   B   C  A - C 5 false
        predecessors[source.indexInMatrix] = source.indexInMatrix               /// 0   1   2      --->  0   1   2
        weights[source.indexInMatrix] = 0                                       /// 0  infi infi         0   2   3      vertexToIndex
        for _ in 0..<vertices.count - 1 {                                       /// count - 1
            var weightUpdated = false
            edges.forEach {                                                     /// edges[A-B:2, B-C:1, A-C:5]
                let weight = $0.weight!
                let relaxDistance = weights[$0.vertexFrom.indexInMatrix] + weight/// 100 < infi        true
                if relaxDistance < weights[$0.vartexTo.indexInMatrix] {          /// infi + 100 < infi false
                    predecessors[$0.vartexTo.indexInMatrix] = $0.vertexFrom.indexInMatrix
                    weights[$0.vartexTo.indexInMatrix] = relaxDistance
                    weightUpdated = true
                }
            }
            guard weightUpdated else { break }
        }
        for edge in edges where weights[edge.vartexTo.indexInMatrix] > weights[edge.vertexFrom.indexInMatrix] + edge.weight! { return nil } /// Is there a negative weight loop?
        return BellmanFordResult(predecessors: predecessors, weights: weights)
    }
}

public struct BellmanFordResult<T: Hashable> {
    fileprivate var predecessors: [Int?]
    fileprivate var weights: [Double]
}

extension BellmanFordResult {
    func distance(vertexTo: Vertex<T>) -> Double? {
        let distance = weights[vertexTo.indexInMatrix]
        guard distance != Double.infinity else { return nil }
        return distance
    }
    func recursePathTo(vertex: Vertex<T>, graph: AdjacencyMatrixGraph<T>) -> [Vertex<T>]? {
        guard weights[vertex.indexInMatrix] != Double.infinity else { return nil }
        guard let predecessorIndex = predecessors[vertex.indexInMatrix] else { return nil }
        let prevVertex = graph.vertices[predecessorIndex]
        if prevVertex.indexInMatrix == vertex.indexInMatrix { return [vertex] }                    /// predecessor    A    B    C
        guard let buildPath = recursePathTo(vertex: prevVertex, graph: graph) else { return nil }///                0    1    2
        return buildPath + [vertex]                                                              ///                0    0    1
    }
}

