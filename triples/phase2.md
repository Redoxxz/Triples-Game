# Phase 2: Triples

## Goals
Use the routines you implemented for assign1 in building the *Triples* game.

## Creating the Project

You will once again need to create a Swift project in Xcode.
For this project, do not select "Include tests", since we will not use them.

## Game Rules
 1. The board consists of a 4x4 grid of rectangles.
 2. Move the board contents Up, Down, Left, and Right, combining compatible
    numbers into their sums.
 3. The game's "goal" is to achieve the highest score, and the game continues
    as long as the player is able to keep moving.

## Board Details
First, set your simulated phone to an **iPhone 12**. This will give us a
common platform.

The elements of your view should be the following:
 * 4 X 4 rectangular "tiles", implemented by `Text View`.
 * A `Button` labeled 'New Game'
 * `Button`s labeled 'Left', 'Right', 'Up', and 'Down'.
 * A `Picker` or `Toggle`, consisting of options "Random"
   (random), and "Determ" (deterministic). 
 * A `Text View` where you will show the current score.

The actions should be as follows:
 * Activating the `New Game` button should cause the game to be restarted,
   calling `newgame()` with the `rand` initializer argument (see below)
   defined by the current state of the picker or toggle, followed by *four*
   `spawn()`s.
 * Activating directional arrows should cause a *collapse* towards the
   indicated direction, followed by a spawn *if the collapse modified the
   board*.
 * Changing Random/Determ does not affect the current game, it only changes
   subsequent games.
 * A running score should be shown in the text view.


## Model Details
Define your model by augmenting the `Triples` model from **assign1** to
ensure the following properties are externally visible:
 * `var board: [[Int]]`
 * `var score: Int`

Property `score` shows the current game score, calculated by
incrementing your total with the value of each new number that appears
in the game. For example, spawns of a '1' and a '2' will add 1 and 2
points, respectively. Combining a '2' and a '1' into a '3' adds 3
points. Combining two '3's into a '6' adds six points, etc. Look at
the running point count in the video if this is unclear.


Your model should also have the following externally-visible methods:
 * `newgame(rand: Bool)` - reinitializes all model state. The value of
   `rand` should be derived from the Random/Deterministic segmented button.
   Note that this method should *not* call `spawn()` (calling `newgame` just
   initializes an empty game). Instead, the "action" for the newgame button
   should call `newgame()`, followed by four `spawn()`s.
 * `collapse(dir: Direction) -> Bool`, collapse the model's board in the
   indicated direction, in place. Return `true` if movement occurred. You
   should define Direction to be an enum consisting of "Left", "Right",
   "Up", and "Down". Coincidentally, these are also the labels of the
   directional buttons.
 * `spawn()`: which randomly chooses to create a new '1' or a '2', and puts
   it in an open tile, if there is one.  See `Randomized and Deterministic Spawning` below.

Your model may have other externally visible controls and state, only
the above is required.  All of this state should be kept in the
`Triples` class defined in a file called `model.swift`.

## Game Play
 * Pressing `New Game` should produce a brand new game on the display, with four
   newly-spawned tiles, each either a "1" or a "2".
 * Pressing `Left`, `Right`, `Up`, or `Down` should cause the underlying model
   to react as in `assign1`. The visible buttons should correspond to that
   model, and the score should be updated.
    * A new tile is spawned afterwards if at least one tile has moved or
      combined with another.
    * When your app determines that there are no more possible moves in any
      direction it displays an alert showing the current score, with an action
      that allows the alert to be dismissed.
 * Pressing either `Random` or `Determ` (deterministic) controls the random
   seed used by future new games. See below.


## Randomized and Deterministic Spawning
Swift has a beautiful new way of creating random values (e.g.
`Int.random(in:... , using: ...`).  We are going to create our own pseudorandom generator
for this method to make the game repeatable for debugging and testing.

You need to create a new file: `Random.swift`, and copy the code below:
```
struct SeededGenerator: RandomNumberGenerator {
    let seed: UInt64
    var curr: UInt64
    init(seed: UInt64 = 0) {
        self.seed = seed
        curr = seed
    }
    
    mutating func next() -> UInt64  {
        curr = (103 &+ curr) &* 65537
        curr = (103 &+ curr) &* 65537
        curr = (103 &+ curr) &* 65537
        return curr
    }
}
```

To create a pseudorandom generator with Seed = 14, your code should be written like this:
```
var seededGenerator = SeededGenerator(seed: 14)
```
To generate a number in 1 to 16 by using this generator, your code would look like:
```
var newRandomNumber = Int.random(in: 1...16, using: &seededGenerator)
```
More generally, you can define (if you prefer)
```
var generator: RandomNumberGenerator = SeededGenerator(seed: 14)
var newRandomNumber = Int.random(in: 1...16, using: &generator)
```
This allows you to use the same syntax with the system random number generator:
```
generator = SystemRandomNumberGenerator()
```
which will provide better randomness. We will refer to `seededGenerator`
below, but you can use either form.


Your app has only two randomized decisions: whether to spawn a '1' or a '2',
and where to put the newly spawned value:
 * '1's and '2's have equal probability. 
 * Choose the open tile to fill by the following:
    * number the open tiles by traversing the grid by row, and left-to-right
      within each row. The first open tile has index `0`.

For example, with:
```
     | 0 1 0 2 |
     | 0 0 3 6 |
     | 1 2 1 1 |
     | 3 3 0 3 |
```

Conceptually number these open spots as follows:
```
     | 0   1  |
     | 2 3    |
     |        |
     |     4  |

```
Choose among them by randomly selecting an index from 0 to 4. You can do this by
running `index = Int.random(in: 0...4, using: &seededGenerator)`. 

Use the randomGenerator to make both random choices. We want your deterministic
mode to exactly match ours, **so use the following ordering**:
 * Use `seededGenerator` to decide the value of the new tile.
 * Use `seededGenerator` to decide where to place the new tile.
 
This ordering is important; otherwise your random decisions may not match ours. 
 
For this assignment, you should:
 * Reinitialize seededGenerator each time starting a new game
 * Use either a random seed in 1 to 1000 if your game mode is `random` or the system
   random number generator. You can use a random seed by running:
   `seededGenerator = SeededGenerator(seed: UInt64(Int.random(in:1...1000)))`
 * **Important** Use seed = 14 if your game mode is `determ`



### Testing

 * Click new game (in random mode) multiple times and see different
   initial conditions, all with 4 buttons displayed, each either a '1' or a '2'
 * Scores are correct. This can be checked even without determinism,
   but in deterministic mode:
    * Click "New Game". Should have a score of 6.
    * Click "new game -> up -> up" should give a score of 11.
 * Determinism works:
    * in deterministic mode a new game reproduces the sequences shown above, i.e.:
       1. Click "new game -> right" results in two 1s in the first row and three 2s in the second row
       2. Click "new game -> down (5 times)" results in a 6 at the bottom right corner 
       
Notes:
 * Your game should look relatively close to the provided video in coloration
   and layout.
 * You do not need to worry about orientation changes.
 * We are not looking at your code other than to look for plagiarism.
 * We do not care if you implement the "tiles" by changing the appearance
   of 16 static views (easiest), or if you use fewer buttons and move
   them about.

