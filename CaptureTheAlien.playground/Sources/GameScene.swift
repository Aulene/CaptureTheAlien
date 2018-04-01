import SpriteKit
public class GameScene: SKScene {
    
    var tileMap: SKTileMapNode!
    var tileSet: SKTileSet!
    var tileSize: CGSize!
    var tileGroups = [SKTileGroup]()
    
    var backgroundTileMap: SKTileMapNode!
    var backgroundTileSet: SKTileSet!
    var backgroundTileGroups = [SKTileGroup]()
    
    var grassTileTexture: SKTexture!
    var waterTileTexture: SKTexture!
    var marsTileTexture: SKTexture!
    var alien: SKSpriteNode!
    
    var grid = [[Int]]()
    var vis = [[Bool]]()
    var dp = [[Int]]()
    var charX: Int!
    var charY: Int!
    var canMoveCharacter: Bool = true
    
    let evenRow = [1, 1, 0, 0, -1, -1]
    let evenCol = [0, -1, 1, -1, 0, -1]
    let oddRow = [1, 1, 0, 0, -1, -1]
    let oddCol = [0, 1, 1, -1, 0, 1]
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        let location = touch.location(in: tileMap)
        
        let row = tileMap.tileRowIndex(fromPosition: location)
        let col = tileMap.tileColumnIndex(fromPosition: location)
        
        if(sanitaryChecks(row: row, col: col)) {
            changeSound()
            changeTile(row: row, col: col)
            canMoveCharacter = moveCharacter()
        }
        
        if(charX == 0 || charX == 10 || charY == 0 || charY == 10) {
            lostSound()
            resetScene()
        }
        
        if(canMoveCharacter == false) {
            winSound()
            resetScene()
        }
    }
    
    public override func didMove(to view: SKView) {
        
        prep()
        mainTiles()
        backgroundTiles()
        createAlien()
        
        loadSceneNodes()
        addButtons()
        
        prepArrays()
        setUpGrid()
    }
    
    public func resetScene() {
        let nextScene = GameScene(size: self.scene!.size)
        self.view?.presentScene(nextScene, transition: SKTransition.fade(with: UIColor.black, duration: 1.5))
    }
    
    public func createAlien() {
        alien = SKSpriteNode(imageNamed: "alien")
        alien.scale(to: CGSize(width: alien.size.width / 2, height: alien.size.height / 2))
        
        moveAlien(row: 5, col: 5)
        alien.zPosition = 2
    }
    
    public func defineTile(tile: SKTexture) {
        
        let tileDefinition = SKTileDefinition(texture: tile, size: self.tileSize)
        let tileGroup = SKTileGroup(tileDefinition: tileDefinition)
        
        self.tileGroups.append(tileGroup)
    }
    
    public func prep() {
        
        self.tileSize = CGSize(width: self.frame.width / 11, height: self.frame.height / 11)
        
        grassTileTexture = SKTexture(imageNamed: "Tiles/grass")
        waterTileTexture = SKTexture(imageNamed: "Tiles/sand")
        marsTileTexture = SKTexture(imageNamed: "Tiles/mars")
        
        defineTile(tile: grassTileTexture)
        defineTile(tile: waterTileTexture)
        defineTile(tile: marsTileTexture)
        
    }
    
    public func addButtons() {
        let resetButton = ResetButton()
        resetButton.zPosition = 2
        resetButton.position = CGPoint(x: 45, y: 45)
        resetButton.delegate = self
        addChild(resetButton)
        
        let titleButton = SKSpriteNode(imageNamed: "titleButton")
        titleButton.zPosition = 2
        titleButton.position = CGPoint(x: frame.width / 2, y: 45)
        addChild(titleButton)
    }
    
    public func backgroundTiles() {
        backgroundTileSet = SKTileSet(tileGroups: tileGroups, tileSetType: .hexagonalPointy)
        
        backgroundTileMap = SKTileMapNode(tileSet: backgroundTileSet, columns: 19, rows: 19, tileSize: tileSize)
        
        backgroundTileMap.fill(with: self.backgroundTileSet.tileGroups[2])
        
        backgroundTileMap.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        backgroundTileMap.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        backgroundTileMap.zPosition = 0
        backgroundTileMap.enableAutomapping = true
    }
    
    public func mainTiles() {
        tileSet = SKTileSet(tileGroups: tileGroups, tileSetType: .hexagonalPointy)
        
        tileMap = SKTileMapNode(tileSet: self.tileSet, columns: 11, rows: 11, tileSize: self.tileSize)
        
        tileMap.fill(with: self.tileSet.tileGroups.first)
        
        tileMap.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        tileMap.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tileMap.zPosition = 1
        
        tileMap.enableAutomapping = true
    }
    
    public func loadSceneNodes() {
        self.addChild(tileMap)
        self.addChild(backgroundTileMap)
        self.addChild(alien)
    }
    
    public func changeTile(row: Int, col: Int) {
        tileMap.setTileGroup(tileSet.tileGroups[1], forColumn: col, row: row)
        grid[row][col] = 1
    }
    
    public func moveAlien(row: Int, col: Int) {
        alien.position = self.convert(tileMap.centerOfTile(atColumn: col, row: row), from: tileMap)
        charX = row;
        charY = col;
    }
    
    public func prepArrays() {
        
        grid = [[Int]](repeating: [Int](repeating: 0, count: 17), count: 17)
        dp = [[Int]](repeating: [Int](repeating: 0, count: 17), count: 17)
        
    }
    
    public func setUpGrid() {
        
        for i in 0...10 {
            for j in 0...10 {
                grid[i][j] = 0
            }
        }
        
        var randomStartTiles = Int(arc4random_uniform(8) + 5)
        
        while randomStartTiles > 0 {
            
            let row = Int(arc4random_uniform(11))
            let col = Int(arc4random_uniform(11))
            
            if(row != 5 && col != 5){
                grid[row][col] = 1
                changeTile(row: row, col: col)
                randomStartTiles = randomStartTiles - 1
            }
        }
        
    }
    
    public func clearGrid() {
        for i in 0...16 {
            for j in 0...16 {
                dp[i][j] = 1007
            }
        }
    }
    
    public func compareAns(prev: [Int], x: Int, y: Int) -> [Int] {
        
        let newAns = dp[x][y]
        var ans = [Int](repeating: 0, count: 3)
        
        if newAns < prev[2] {
            ans[0] = x
            ans[1] = y
            ans[2] = newAns
            return ans
        }
        else { return prev }
        
    }
    
    public func bfs() {
        
        var q = Queue<graphNode>()
        var top = graphNode()
        var dummy = graphNode()
        
        for i in 0...10 {
            
            dummy.row = 0
            dummy.col = i
            dummy.dist = 1
            
            if(grid[dummy.row][dummy.col] == 0) {
                q.push(dummy)
                dp[dummy.row][dummy.col] = 1
            }
            
            dummy.row = 10
            if(grid[dummy.row][dummy.col] == 0) {
                q.push(dummy)
                dp[dummy.row][dummy.col] = 1
            }
        }
        
        for i in 1...9 {
            
            dummy.col = 0
            dummy.row = i
            dummy.dist = 1
            
            if(grid[dummy.row][dummy.col] == 0) {
                q.push(dummy)
                dp[dummy.row][dummy.col] = 1
            }
            
            dummy.col = 10
            q.push(dummy)
            if(grid[dummy.row][dummy.col] == 0) {
                q.push(dummy)
                dp[dummy.row][dummy.col] = 1
            }
        }
        
        while q.empty == false {
            
            top = q.front!
            q.pop()
            
            let row = top.row!
            let col = top.col!
            let dist = top.dist!
            
            if(row % 2 == 0) {
                
                for i in 0...5 {
                    let rowx = row + evenRow[i]
                    let colx = col + evenCol[i]
                    if(sanitaryChecks(row: rowx, col: colx)) {
                        if(dp[rowx][colx] > dp[row][col] + 1) {
                            
                            dp[rowx][colx] = dist + 1
                            dummy.row = rowx
                            dummy.col = colx
                            dummy.dist = dp[rowx][colx]
                            
                            q.push(dummy)
                        }
                    }
                    
                }
            }
            else {
                
                for i in 0...5 {
                    
                    let rowx = row + oddRow[i]
                    let colx = col + oddCol[i]
                    
                    if(sanitaryChecks(row: rowx, col: colx)) {
                        if(dp[rowx][colx] > dp[row][col] + 1) {
                            
                            dp[rowx][colx] = dist + 1
                            dummy.row = rowx
                            dummy.col = colx
                            dummy.dist = dp[rowx][colx]
                            
                            q.push(dummy)
                        }
                    }
                    
                }
                
            }
            
        }
    }
    
    public func moveCharacter() -> Bool {
        
        clearGrid()
        bfs()
        
        var ans = [Int](repeatElement(0, count: 3))
        ans[0] = 0
        ans[1] = 0
        ans[2] = 1007
        
        if(charX % 2 == 0) {
            for i in 0...5 {
                ans = compareAns(prev: ans, x: charX + evenRow[i], y: charY + evenCol[i])
            }
        }
        else {
            for i in 0...5 {
                ans = compareAns(prev: ans, x: charX + oddRow[i], y: charY + oddCol[i])
            }
        }
        
        
        if(ans[2] < 207) {
            charX = ans[0]
            charY = ans[1]
            moveAlien(row: charX, col: charY)
            moveSound()
            return true
        }
        else { return false }
    }
    
    public func sanitaryChecks(row: Int, col: Int) -> Bool {
        
        if(row > 10 || row < 0 || col > 10 || col < 0) { return false }
        if((row == charX && col == charY) || (grid[row][col] == 1)) { return false }
        return true
    }
    
    public func changeSound() {
        let sound = SKAction.playSoundFileNamed("Sounds/click.mp3", waitForCompletion: true)
        run(sound)
    }
    
    public func moveSound() {
        let sound = SKAction.playSoundFileNamed("Sounds/move.mp3", waitForCompletion: true)
        run(sound)
    }
    
    public func lostSound() {
        let sound = SKAction.playSoundFileNamed("Sounds/loss.mp3", waitForCompletion: true)
        run(sound)
    }
    
    public func winSound() {
        let sound = SKAction.playSoundFileNamed("Sounds/win.mp3", waitForCompletion: true)
        run(sound)
    }
}

extension GameScene: ResetButtonDelegate {
    
    public func didTapReset(sender: ResetButton) { resetScene() }
}
