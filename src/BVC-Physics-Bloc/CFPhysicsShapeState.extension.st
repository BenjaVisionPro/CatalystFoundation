Extension { #name : 'CFPhysicsShapeState' }

{ #category : '*BVC-Physics-Bloc' }
CFPhysicsShapeState >> captureCollisionGeometryForExtent: anExtent [
	^ CFPhysicsBlocShapeFactory
		collisionGeometryFor: self element geometry
		extent: anExtent
]

{ #category : '*BVC-Physics-Bloc' }
CFPhysicsShapeState >> polygonShape [
	^ CFPhysicsBlocShapeFactory polygonShapeFor: self
]
