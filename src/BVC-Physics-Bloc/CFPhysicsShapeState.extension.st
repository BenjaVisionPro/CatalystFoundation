Extension { #name : 'CFPhysicsShapeState' }

{ #category : '*BVC-Physics-Bloc' }
CFPhysicsShapeState >> captureCollisionGeometryForExtent: anExtent [
	^ CFPhysicsBlocGeometryBuilder
		collisionGeometryFor: self element geometry
		extent: anExtent
]

{ #category : '*BVC-Physics-Bloc' }
CFPhysicsShapeState >> polygonShape [
	^ CFPhysicsShapeBuilder polygonShapeFor: self
]
