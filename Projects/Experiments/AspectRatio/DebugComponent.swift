//
//  DebugComponent.swift
//  GameMechanics
//
//  Created by Richard Henry on 01/05/2020.
//  Copyright © 2020 Dogstar Industries Ltd. All rights reserved.
//

import GameplayKit

public class DebugComponent: GKComponent {
    
    @GKInspectable var identifier: String = UUID().uuidString
    @GKInspectable var dumpTiming: Bool = false
    @GKInspectable var nearest: Bool = false

    var spriteComponent : GKSKNodeComponent? { entity?.component(ofType: GKSKNodeComponent.self) }

    deinit { print(" \(self.identifier) \(self) deinits") }
    
    // MARK: Update
    
    public override func update(deltaTime: TimeInterval) {
        
        super.update(deltaTime: deltaTime)
        
        if dumpTiming { print("\(self) update at \(deltaTime)s") }
    }
    
    public override func didAddToEntity() {
        
        print("DebugComponent '\(self.identifier)' (\(self)) added to entity: \(String(describing: entity))")
        print("Sprite component on add: \(String(describing: spriteComponent))")
        
        if nearest { (spriteComponent?.node as? SKSpriteNode)?.texture?.filteringMode = .nearest }
    }
    
    public override func willRemoveFromEntity() {
        
        print("Component \(self) will remove from entity \(String(describing: entity))")
        //print("Sprite component on remove: \(String(describing: entity?.spriteComponent))")
    }
    
    public override class var supportsSecureCoding: Bool { return true }
}
