//
//  TripPlannerTests.swift
//  TripPlannerTests
//
//  Created by James Pereira on 2018/11/06.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import XCTest

@testable import TripPlanner

class TripPlannerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUsingBellmanFord() {
        
        var graph = AdjacencyMatrixGraph<String>()
        let vertexA = graph.createVertex("A")
        let vertexB = graph.createVertex("B")
        let vertexC = graph.createVertex("C")
        let vertexD = graph.createVertex("D")
        let vertexE = graph.createVertex("E")
        ///       2
        graph.addDirectEdge(lhs: vertexA, rhs: vertexB, weight: 2)      ///   A ----- B
        graph.addDirectEdge(lhs: vertexB, rhs: vertexC, weight: 1)      ///   | \     |  1
        graph.addDirectEdge(lhs: vertexA, rhs: vertexC, weight: 5.5)    ///   5------ C
        graph.addDirectEdge(lhs: vertexA, rhs: vertexD, weight: 1)      ///       \ 1 D  1
        graph.addDirectEdge(lhs: vertexC, rhs: vertexD, weight: 1)      ///        +  D
        graph.addDirectEdge(lhs: vertexD, rhs: vertexE, weight: 4.5)    ///         \ E  4.5
        
        let bellManResult = graph.apply(source: vertexA)
        //let vertexArray = bellManResult?.recursePathTo(vertex: vertexC, graph: graph)
        //vertexArray?.forEach { print($0.data) } //A B C
        let distance = bellManResult?.distance(vertexTo: vertexE) ?? 0.0
        print(distance)
        XCTAssert(distance==5.5, "Failed to calculate shortest path (weighted) -> result was \(distance)")
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
