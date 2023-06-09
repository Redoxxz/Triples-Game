# Phase 1: Swift and Extensions   

## Goals
The primary goal of this project is to to familiarize yourself with
the environment and the language. All in this class will be written
in Swift 5.1, using XCode 11 or later as your friendly development
environment.  *Errors resulting from development in different
environments still result in loss of points.*

Specifically, you will do the following:
1. create a standard iOS app, "*assign1*" that does nothing
   (other than compile and show a blank screen), but does include a
   model of our app: "Triples".

In the process you will obviously learn quite a bit about the `XCode`
environment, about unit tests in the context of Swift applications,
and about defining type extensions.

## Using git
You will submit your assignment solution through git. Remember to
add and commit all of your source code files.  See
https://gitlab.cs.umd.edu/mmarsh/git-tutorial for more about using
git.

You will have to push your repository back up to gitlab -- this is
how you will submit it. You should add, commit, and push frequently,
so that
 1. you do not lose work, and
 2. we can help answer your questions.

# Building An App
We are going to build an app called `Triples` in three stages. In
the first stage, we are just going to design and implement the
model, and unit-test it.

As we did in class, you will create a new iOS app:
- Create a new project in XCode and save to your `assign1` git repository
  directory. 
- When creating the project:
  - also call it `assign1`
  - **check "unit tests"**, uncheck `git`
  - select an iOS app even though we will not have any graphical
    characteristics
- Note that new files must be explicitly added to git via `git add <file>...`.

Create a new file `model.swift` in the app by selecting "New File"
from the, and then selecting the Swift file icon in the dialog, and
name it `model.swift`.  `model.swift` will contain the "model" known
from the model-view-controller (MVC) or model-view-viewmodel paradigms.

## App Logic
Our game action will be similar to the app `Threes` on the apple
and android app stores. A portion of the game play is shown in the
file `assign1DemoThrees.mp4`, which you can find on ELMS.


## Your Tasks
Your tasks are to implement the *model* behind the gameplay shown
in the clip. Specifically, you will implement the "collapse", which
given a swipe in a direction collapses each row or column parallel
to the swipe by eliminating a blank, combining a 1 and a 2, or
combining two consecutive tiles w/ the same value, 3 or higher.
For more specifics, see the tests described below.

## The `Triples` Class

In the file `model.swift` you need to define a new class `Triples`,
which implements the methods discussed below. Most importantly,
`Triples` will need the following definitions:
```
     var board: [[Int]]

     func newgame() {}                   // re-inits 'board', and any other state you define
     func rotate() {}                    // rotate a square 2D Int array clockwise
     func shift() {}                     // collapse to the left
     func collapse(dir: Direction) {}    // collapse in specified direction using shift() and rotate()
```
Note that methods merely modify the `board` property. We are not
taking any actions based on the board, or doing any GUI work at
all.  `Direction` is an `enum` that you will define for the four
directions referenced below.

Outside `Triples`, you will need to build two other functions, one
of which should be called in your `rotate()` method (ideally the
generic, but the explicit `Int` version is fine if you don't get
the generic working).  The first is:
```
     // class-less function that will return of any square 2D Int array rotated clockwise
     public func rotate2DInts(input: [[Int]]) -> [[Int]] {}  
```
You should also build `rotate2D`, which is a *generic* version of
the above.

### Unit Tests
Copy the following unit tests verbatim into your file `assign1Tests.swift`.
Do no change anything, as we will use the exact tests below to test
your definitions in `model.swift`.
```
    func testSetup() {
        let game = Triples()
        game.newgame()
        
        XCTAssertTrue((game.board.count == 4) && (game.board[3].count == 4))
    }
```
Tests to ensure your app defines a 4x4 2D array of `Int`s.

### Rotate
Build a func `rotate2DInts` that will take any 2D Int array and
rotate it once clockwise. Your func may assume that the array is
square.
```
    func testRotate1() {
        var board = [[0,3,3,3],[1,2,3,3],[0,2,1,3],[3,3,6,6]]
        board = rotate2DInts(input: board)
        XCTAssertTrue(board == [[3,0,1,0],[3,2,2,3],[6,1,3,3],[6,3,3,3]])
    }
```

### Generic Rotate
Same test using a generic func you must write called `rotate2D`,
and which will work on any type of array.
```
    func testRotate2() {
        var board = [[0,3,3,3],[1,2,3,3],[0,2,1,3],[3,3,6,6]]
        board = rotate2D(input: board)
        XCTAssertTrue(board == [[3,0,1,0],[3,2,2,3],[6,1,3,3],[6,3,3,3]])
    }
```

Try again with strings.
```
    func testRotate3() {
        var board = [["0","3","3","3"],["1","2","3","3"],["0","2","1","3"],["3","3","6","6"]]
        board = rotate2D(input: board)
        XCTAssertTrue(board == [["3","0","1","0"],["3","2","2","3"],["6","1","3","3"],["6","3","3","3"]])
    }
```

### Collapsing
Write a `shift()` method that collapses each row to the left (as
if w/ a left swipe in the clip).
```
    func testShift() {
        let game = Triples()
        game.board = [[0,3,3,3],[1,2,3,3],[0,2,1,3],[3,3,6,6]]
        game.shift()
        XCTAssertTrue(game.board == [[3,3,3,0],[3,3,3,0],[2,1,3,0],[6,6,6,0]])
    }
```

Write and test a `collapse()` method will take a `Direction`
enumeration collapse in the direction specified. Internally, you
should build `collapse` using `shift()` and `rotate()`.
```
    func testLeft() {
        let game = Triples()
        game.board = [[0,3,3,3],[1,2,3,3],[0,2,1,3],[3,3,6,6]]
        game.collapse(dir: .left)
        XCTAssertTrue(game.board == [[3,3,3,0],[3,3,3,0],[2,1,3,0],[6,6,6,0]])
    }

    func testRight() {
        let game = Triples()
        game.board = [[0,3,3,3],[1,2,3,3],[0,2,1,3],[3,3,6,6]]
        game.collapse(dir: .right)
        XCTAssertTrue(game.board == [[0,0,3,6],[0,1,2,6],[0,0,3,3],[0,3,3,12]])

    }

    func testDown() {
        let game = Triples()
        game.board = [[0,3,3,3],[1,2,3,3],[0,2,1,3],[3,3,6,6]]
        game.collapse(dir: .down)
        XCTAssertTrue(game.board == [[0,3,0,0],[0,2,6,3],[1,2,1,6],[3,3,6,6]])
    }

    func testUp() {
        let game = Triples()
        game.board = [[0,3,3,3],[1,2,3,3],[0,2,1,3],[3,3,6,6]]
        game.collapse(dir: .up)
        XCTAssertTrue(game.board == [[1,3,6,6],[0,2,1,3],[3,2,6,6],[0,3,0,0]])
    }
```


# Notes
- Remember, frequently save your work on gitlab.  We will download
  your repository from gitlab directly.

