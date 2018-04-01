import PlaygroundSupport
import SpriteKit

/*:
 
 # Capture the Alien!
 ## A puzzle game
 
 Neo, an alien from Mars, wants to escape the green grid. Your mission, should you choose to accept it, is to capture him!
 
 ## How to Play
 The game is simple. You click on a grass tile to change it to a sand tile, and Neo is unable to move on it. After your move, Neo moves to a tile that is adjacent to his current position.
 
 If Neo reaches the edge of the grid, you lose.
 Your objective is to encircle Neo with sand tiles, such that he is trapped and cannot move to the edge.
 
 Made with ❤️ by Aulene De.
*/

let frame = CGRect(x: 0, y: 0, width: 600, height: 600)
let sz = CGSize(width: 600, height: 600)

let sceneView = SKView(frame: frame)
let scene = GameScene(size: sz)
sceneView.presentScene(scene)

PlaygroundPage.current.liveView = sceneView
