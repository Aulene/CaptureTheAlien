import SpriteKit

public struct graphNode {
    public var row: Int!
    public var col: Int!
    public var dist: Int!
}

public struct Queue<T> {
    public var array = [T]()
    
    public var empty: Bool { return array.isEmpty }
    
    public mutating func push(_ element: T) { array.append(element) }
    
    public mutating func pop() {
        if empty == false { array.removeFirst() }
    }
    
    public var front: T? { return array.first }
}
