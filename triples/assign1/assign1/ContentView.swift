//
//  ContentView.swift
//  assign1
//
//  Created by Mohammad Ahmad on 4/29/23.
//

import SwiftUI
import Foundation

struct Tile {
    let id: Int
    var val: Int
    var row: Int
    var col: Int
}

struct TileView: View {
    var tile: Tile?
    
    var body: some View {
        if let tile = tile {
            Text("\(tile.val)")
                .frame(width: 40, height: 40)
                .padding(20)
                .background(colorForTile(tile.val))
            
        } else {
            Text("")
                .frame(width: 40, height: 40)
                .padding(20)
                .background(.yellow.opacity(0.2))
        }
    }
    
    private func colorForTile(_ value: Int) -> Color {
        switch value {
        case 1:
            return .blue
        case 2:
            return .red
        default:
            return .green
        }
    }
}

struct ContentView: View {
    
    @State public var board: [[Tile?]] =  Array(repeating: Array(repeating: nil, count: 4), count: 4)
    @State public var score = 0
    @State private var rand: Bool = true
    @State private var seededGenerator: RandomNumberGenerator = SeededGenerator(seed: 14)
    @State private var generator = SystemRandomNumberGenerator()
    @State private var gameEnd = false
    @State private var offsets: [[CGSize]] = Array(repeating: Array(repeating: .zero, count: 4), count: 4)
    @State private var direction: Direction = .down
    @State var highScores: [Int: Date] = [300: Date().addingTimeInterval(3600), 400: Date()]
    @State private var rotateDegrees = 0.0
    @State private var scale: CGFloat = 1.0
    @GestureState private var translation: CGSize = .zero
    
    var body: some View {
        TabView(){
            Text("CMSC436")
                .rotationEffect(.degrees(rotateDegrees))
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(Animation.linear(duration: 5).repeatForever(autoreverses: false)) {
                        rotateDegrees += 360
                    }
                    withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        scale = 2.0
                    }
                }
                .tabItem{
                    Text("About")
                }
            VStack {
                Text("Score: \(score)")
                    .frame(width: 120, height: 40)
                    .background(.red)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                ForEach (0..<board.count, id: \.self) { row in
                    HStack {
                        ForEach (0..<self.board[row].count, id: \.self) {col in
                            TileView(tile: board[row][col])
                                .offset(self.offsets[row][col])
                                .animation(.easeInOut(duration: 1.0))
                            
                        }
                        
                    }
                }
                Button(action: {
                    collapse(dir: .up)
                    spawn()
                }) {
                    Text("Up")
                        .frame(width: 80, height: 40)
                        .background(.blue)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }.alert(isPresented: $gameEnd) {
                    Alert(title: Text("Game Over"), message: Text("Your score is \(score)"), dismissButton: .default(Text("I suck")){
                        highScores[score] = Date()
                        newgame(random: rand)
                    })
                }
                HStack {
                    Button(action: {
                        collapse(dir: .left)
                        spawn()
                    }) {
                        Text("Left")
                            .frame(width: 80, height: 40)
                            .background(.blue)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                            .gesture(
                                DragGesture()
                            )
                    }.alert(isPresented: $gameEnd) {
                        Alert(title: Text("Game Over"), message: Text("Your score is \(score)"), dismissButton: .default(Text("I suck")){
                            highScores[score] = Date()
                            newgame(random: rand)
                        })
                    }
                    Button(action: {
                        collapse(dir: .right)
                        spawn()
                    }) {
                        Text("Right")
                            .frame(width: 80, height: 40)
                            .background(.blue)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }.alert(isPresented: $gameEnd) {
                        Alert(title: Text("Game Over"), message: Text("Your score is \(score)"), dismissButton: .default(Text("I suck")){
                            highScores[score] = Date()
                            newgame(random: rand)
                        })
                    }
                }
                Button(action: {
                    collapse(dir: .down)
                    spawn()
                }) {
                    Text("Down")
                        .frame(width: 80, height: 40)
                        .background(.blue)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }.alert(isPresented: $gameEnd) {
                    Alert(title: Text("Game Over"), message: Text("Your score is \(score)"), dismissButton: .default(Text("I suck")){
                        highScores[score] = Date()
                        newgame(random: rand)
                    })
                }
                Button(action: {
                    newgame(random: rand)
                    spawn()
                    spawn()
                    spawn()
                    spawn()
                }) {
                    Text("New Game")
                        .frame(width: 100, height: 40)
                        .background(.green)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                Picker("Game Mode", selection: $rand) {
                    Text("Random").tag(true)
                    Text("Determ").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .gesture(
                DragGesture()
                    .updating($translation) { current, state, _ in
                        state = current.translation
                    }
                    .onEnded { final in
                        // Check if the drag was more horizontal or vertical
                        if abs(final.translation.width) > abs(final.translation.height) {
                            // Dragged horizontally
                            if final.translation.width < 0 {
                                // Dragged left, perform the action of the "left" button
                                self.collapse(dir: .left)
                                self.spawn()
                            } else {
                                // Dragged right, perform the action of the "right" button
                                self.collapse(dir: .right)
                                self.spawn()
                            }
                        } else {
                            // Dragged vertically
                            if final.translation.height < 0 {
                                // Dragged up, perform the action of the "up" button
                                self.collapse(dir: .up)
                                self.spawn()
                            } else {
                                // Dragged down, perform the action of the "down" button
                                self.collapse(dir: .down)
                                self.spawn()
                            }
                        }
                    }
            )
            .tabItem{
                Text("Game")
            }
            List(){
                var sortedKeys: [Int] {
                    highScores.keys.sorted(by: >)
                }
                ForEach(sortedKeys, id: \.self) { key in
                    if let value = highScores[key]{
                        VStack(alignment: .leading) {
                            Text("Score: \(key)")
                            Text("Date: \(value)")
                        }
                    }
                }
            }.tabItem{
                Text("HighScores")
            }
        }
        
    }
    public func newgame(random: Bool){
        gameEnd = false
        generator = SystemRandomNumberGenerator()
        seededGenerator = SeededGenerator(seed: 14)
        //reset board
        board = []
        //resets score
        score = 0
        
        //reinit board
        board = Array(repeating: Array(repeating: nil, count: 4), count: 4)
        
        //share if random or determ bool
        rand = random
    }
    
    public func spawn() {
        // checks if there is any open spots on the board, open array slots all open indexes
        var open: [(Int, Int)] = []
        var count = 0
        for x in 0..<board.count {
            for y in 0..<board[x].count {
                if board[x][y] == nil {
                    open.append((x,y))
                } else {
                    count += 1
                }
            }
        }
        //returns if there are no open slots
        if count == 16{
            var fake: [[Tile?]] = Array(repeating: Array(repeating: nil, count: 4), count: 4)
            let fakeScore = score
            for x in 0...board.count - 1{
                for i in 0...board[x].count - 1{
                    fake[x][i] = board[x][i]
                }
            }
            collapse(dir: .up)
            if fakeScore == score{
                collapse(dir: .down)
                if fakeScore == score{
                    collapse(dir: .right)
                    if fakeScore == score{
                        collapse(dir: .left)
                        if fakeScore == score{
                            gameEnd = true
                        }
                    }
                }
            }
            for x in 0...board.count - 1{
                for i in 0...board[x].count - 1{
                    score = fakeScore
                    board[x][i] = fake[x][i]
                }
            }
            return
        }
        //generates random input
        if rand {
            let newRandomNumber = Int.random(in: 1...2, using: &generator)
            let newRandomIndex = Int.random(in: 0..<open.count, using: &generator)
            let (col, row) = open[newRandomIndex]
            let tileID = col * 4 + row
            board[col][row] = Tile(id: tileID, val: newRandomNumber, row: row, col: col)
            score += newRandomNumber
            
        } //generates random input based on seed/determ
        else {
            let newRandomNumber = Int.random(in: 1...2, using: &seededGenerator)
            let newRandomIndex = Int.random(in: 0..<open.count, using: &seededGenerator)
            let (col, row) = open[newRandomIndex]
            let tileID = col * 4 + row
            board[col][row] = Tile(id: tileID, val: newRandomNumber, row: row, col: col)
            score += newRandomNumber
        }
        
    }
    
    public func rotate() {
        board = rotate2DInts(input: board)
    }
    
    func shift() {
        var count = 0
        for x in 0..<board.count {
            for _ in 0..<board[x].count {
                count += 1
            }
        }
        for x in 0..<board.count {
            for i in 1..<board[x].count {
                if let currentTile = board[x][i] {
                    
                    
                    
                    if let leftTile = board[x][i-1] {
                        if (currentTile.val == leftTile.val) && ((currentTile.val == 1) || (currentTile.val == 2)){
                            //nothing
                        }
                        else if (currentTile.val == leftTile.val) ||
                                    (currentTile.val == 1 && leftTile.val == 2) ||
                                    (currentTile.val == 2 && leftTile.val == 1)
                        {
                            if direction == .left{
                                offsets[x][i] = CGSize(width: -350, height: 0)
                            }
                            else if direction == .right{
                                offsets[x][i] = CGSize(width: 350, height: 0)
                            }
                            else if direction == .up{
                                offsets[x][i] = CGSize(width: 0, height: -350)
                            }
                            else if direction == .down{
                                offsets[x][i] = CGSize(width: 0, height: 350)
                            }
                            let newValue = currentTile.val + leftTile.val
                            withAnimation(.easeInOut(duration: 1.0)) {
                                board[x][i-1] = Tile(id: leftTile.id, val: newValue, row: i-1, col: x)
                                board[x][i] = nil
                                score += newValue
                                offsets[x][i] = .zero
                            }
                            
                        } else if leftTile.val == 0 {
                            if direction == .left{
                                offsets[x][i] = CGSize(width: -350, height: 0)
                            }
                            else if direction == .right{
                                offsets[x][i] = CGSize(width: 350, height: 0)
                            }
                            else if direction == .up{
                                offsets[x][i] = CGSize(width: 0, height: -350)
                            }
                            else if direction == .down{
                                offsets[x][i] = CGSize(width: 0, height: 350)
                            }
                            withAnimation(.easeInOut(duration: 1.0)) {
                                board[x][i-1] = currentTile
                                board[x][i] = nil
                                offsets[x][i] = .zero
                            }
                        }
                    } else {
                        if direction == .left{
                            offsets[x][i] = CGSize(width: -350, height: 0)
                        }
                        else if direction == .right{
                            offsets[x][i] = CGSize(width: 350, height: 0)
                        }
                        else if direction == .up{
                            offsets[x][i] = CGSize(width: 0, height: -350)
                        }
                        else if direction == .down{
                            offsets[x][i] = CGSize(width: 0, height: 350)
                        }
                        withAnimation(.easeInOut(duration: 1.0)) {
                            board[x][i-1] = Tile(id: currentTile.id, val: currentTile.val, row: currentTile.row, col: currentTile.col)
                            board[x][i] = nil
                            offsets[x][i] = .zero
                        }
                    }
                    withAnimation(.easeInOut(duration: 1.0)) {
                        offsets[x][i] = .zero
                    }
                }
            }
        }
    }
    
    
    // collapse in specified direction using shift() and rotate()
    public func collapse(dir: Direction) {
        direction = dir
        if dir == .up{
            rotate()
            rotate()
            rotate()
            shift()
            rotate()
        }
        else if dir == .down {
            rotate()
            shift()
            rotate()
            rotate()
            rotate()
        }
        else if dir == .left {
            shift()
        }
        else if dir == .right {
            rotate()
            rotate()
            shift()
            rotate()
            rotate()
        }
    }
    
}

private func rotate2DInts(input: [[Tile?]]) -> [[Tile?]] {
    var board: [[Tile?]] = Array(repeating: Array(repeating: nil, count: 4), count: 4)
    for x in 0..<input.count {
        var count = 3
        for y in 0..<input[x].count {
            board[x][y] = input[count][x]
            count -= 1
        }
    }
    return board
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
