Extension { #name : 'CFPhysicsShapeState' }

{ #category : '*BVC-Physics-Bloc' }
CFPhysicsShapeState >> polygonShape [
	^ CFPhysicsBlocShapeFactory polygonShapeFor: self
]
