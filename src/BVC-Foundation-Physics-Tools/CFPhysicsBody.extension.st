Extension { #name : 'CFPhysicsBody' }

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsBody >> physicsOverlayElementIn: aContext [
	^ CFPhysicsBodyOverlayElement on: self context: aContext
]
