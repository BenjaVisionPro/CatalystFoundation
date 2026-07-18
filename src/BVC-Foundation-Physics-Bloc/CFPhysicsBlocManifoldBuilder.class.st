Class {
	#name : 'CFPhysicsBlocManifoldBuilder',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Bloc',
	#package : 'BVC-Foundation-Physics-Bloc'
}

{ #category : 'collision' }
CFPhysicsBlocManifoldBuilder class >> manifoldBetweenBody: bodyA andBody: bodyB [
	| shapeA shapeB |
	shapeA := bodyA shapeState polygonShape.
	shapeB := bodyB shapeState polygonShape.
	(shapeA isNil or: [ shapeB isNil ]) ifTrue: [ ^ nil ].
	^ CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: shapeA
		position: bodyA position
		rotation: bodyA rotation
		andShape: shapeB
		position: bodyB position
		rotation: bodyB rotation
]

{ #category : 'collision' }
CFPhysicsBlocManifoldBuilder class >> manifoldBetweenShapeState: shapeStateA position: positionA rotation: rotationA andShapeState: shapeStateB position: positionB rotation: rotationB [
	| shapeA shapeB |
	shapeA := shapeStateA polygonShape.
	shapeB := shapeStateB polygonShape.
	(shapeA isNil or: [ shapeB isNil ]) ifTrue: [ ^ nil ].
	^ CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: shapeA
		position: positionA
		rotation: rotationA
		andShape: shapeB
		position: positionB
		rotation: rotationB
]
