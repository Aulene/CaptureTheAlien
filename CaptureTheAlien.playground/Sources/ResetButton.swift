import SpriteKit

public protocol ResetButtonDelegate: class {
    func didTapReset(sender: ResetButton)
}

public class ResetButton: SKSpriteNode {
    
    public var delegate: ResetButtonDelegate?
    
    public init() {
        let texture = SKTexture(imageNamed: "resetButton")
        let color = SKColor.red
        let size = CGSize(width: 49, height: 49)
        
        super.init(texture: texture, color: color, size: size)
        
        isUserInteractionEnabled = true
        zPosition = 1
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        alpha = 0.5
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let alphaAction = SKAction.fadeAlpha(to: 0.5, duration: 0.10)
        alphaAction.timingMode = .easeInEaseOut
        run(alphaAction)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        delegate?.didTapReset(sender: self)
    }
    
    
}
