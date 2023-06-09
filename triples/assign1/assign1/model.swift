//
//  model.swift
//  assign1
//
//  Created by Mohammad Ahmad on 4/29/23.
//

import Foundation
import SwiftUI

@main
struct model: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

public var board: [[Int]] = []
public var score = 0
public var rand: Bool = true

public enum Direction {
    case left
    case right
    case up
    case down
    case none
}

struct Score: Hashable {
    var score: Int
    var time: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(time)
    }
    
    init(score: Int, time: Date) {
        self.score = score
        self.time = time
    }
}


public class Triples {

    var board: [[Int]] = []
    var score = 0
    var rand: Bool = true
    
    // re-inits 'board', and any other state you define
    func newgame() {
        board = []
        score = 0
        board.append([0, 0, 0, 0])
        board.append([0, 0, 0, 0])
        board.append([0, 0, 0, 0])
        board.append([0, 0, 0, 0])
    }
}

public func rotate2D<T>(input: [[T]]) -> [[T]] {
    var output = [[T]]()
    let n = input.count
        var array = [T]()
        for y in 0..<n {
            for z in stride(from: n-1, to: -1, by: -1) {
                array.append(input[z][y])
            }
            output.append(array)
            array = [T]()
        }
    return output
}
