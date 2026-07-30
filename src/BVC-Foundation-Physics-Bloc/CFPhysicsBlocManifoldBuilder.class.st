Class {
	#name : 'CFPhysicsBlocManifoldBuilder',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Bloc',
	#package : 'BVC-Foundation-Physics-Bloc'
}

{ #category : 'collision' }
CFPhysicsBlocManifoldBuilder class >> manifoldBetweenBody: bodyA andBody: bodyB [
	^ self
		manifoldBetweenShapeState: bodyA shapeState
		position: bodyA position
		rotation: bodyA rotation
		andShapeState: bodyB shapeState
		position: bodyB position
		rotation: bodyB rotation
]

{ #category : 'collision' }
CFPhysicsBlocManifoldBuilder class >> manifoldBetweenBodyState: bodyStateA andBodyState: bodyStateB [
	| firstTransform secondTransform |
	firstTransform := bodyStateA currentTransform.
	secondTransform := bodyStateB currentTransform.
	^ self
		manifoldBetweenShapeState: bodyStateA shapeState
		position: (bodyStateA shapeState elementPositionForBodyOrigin: firstTransform bodyOrigin)
		rotation: firstTransform rotation
		andShapeState: bodyStateB shapeState
		position: (bodyStateB shapeState elementPositionForBodyOrigin: secondTransform bodyOrigin)
		rotation: secondTransform rotation
]

{ #category : 'collision' }
CFPhysicsBlocManifoldBuilder class >> manifoldBetweenShapeState: shapeStateA position: positionA rotation: rotationA andShapeState: shapeStateB position: positionB rotation: rotationB [
	(shapeStateA isCircle and: [ shapeStateB isCircle ]) ifTrue: [
		^ CFPhysicsCircleManifoldBuilder
			manifoldBetweenCircleShapeState: shapeStateA
			position: positionA
			rotation: rotationA
			andCircleShapeState: shapeStateB
			position: positionB
			rotation: rotationB ].
	shapeStateA isCircle ifTrue: [
		^ CFPhysicsCircleManifoldBuilder
			manifoldBetweenCircleShapeState: shapeStateA
			position: positionA
			rotation: rotationA
			andPolygonShapeState: shapeStateB
			position: positionB
			rotation: rotationB ].
	shapeStateB isCircle ifTrue: [
		^ CFPhysicsCircleManifoldBuilder
			manifoldBetweenPolygonShapeState: shapeStateA
			position: positionA
			rotation: rotationA
			andCircleShapeState: shapeStateB
			position: positionB
			rotation: rotationB ].
	^ self
		manifoldBetweenPolygonShapeState: shapeStateA
		position: positionA
		rotation: rotationA
		andPolygonShapeState: shapeStateB
		position: positionB
		rotation: rotationB
]

{ #category : 'private - collision' }
CFPhysicsBlocManifoldBuilder class >> manifoldBetweenPolygonShapeState: shapeStateA position: positionA rotation: rotationA andPolygonShapeState: shapeStateB position: positionB rotation: rotationB [
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
