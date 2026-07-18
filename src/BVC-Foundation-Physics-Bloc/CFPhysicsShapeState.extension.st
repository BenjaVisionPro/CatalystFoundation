Extension { #name : 'CFPhysicsShapeState' }

{ #category : '*BVC-Foundation-Physics-Bloc' }
CFPhysicsShapeState >> polygonShape [
	^ CFPhysicsBlocShapeFactory polygonShapeFor: self
]
