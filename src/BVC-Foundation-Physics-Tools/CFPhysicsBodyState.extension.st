Extension { #name : 'CFPhysicsBodyState' }

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsBodyState >> physicsOverlayElementIn: aContext [
	^ CFPhysicsBodyOverlayElement on: self context: aContext
]
