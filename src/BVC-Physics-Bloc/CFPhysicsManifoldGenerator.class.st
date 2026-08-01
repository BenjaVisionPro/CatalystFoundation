"
I generate collision manifolds from the shape state owned by Physics bodies.

My responsibility is to derive authoritative contact geometry from Physics bodies, captured body states, or shape states at explicit transforms.
"
Class {
	#name : 'CFPhysicsManifoldGenerator',
	#superclass : 'Object',
	#category : 'BVC-Physics-Bloc',
	#package : 'BVC-Physics-Bloc'
}

{ #category : 'collision' }
CFPhysicsManifoldGenerator >> manifoldBetweenBody: bodyA andBody: bodyB [
	^ self
		manifoldBetweenShapeState: bodyA shapeState
		bodyOrigin: bodyA worldBodyOrigin
		rotation: bodyA rotation
		andShapeState: bodyB shapeState
		bodyOrigin: bodyB worldBodyOrigin
		rotation: bodyB rotation
]

{ #category : 'collision' }
CFPhysicsManifoldGenerator >> manifoldBetweenBodyState: bodyStateA andBodyState: bodyStateB [
	| firstTransform secondTransform |
	firstTransform := bodyStateA currentTransform.
	secondTransform := bodyStateB currentTransform.
	^ self
		manifoldBetweenShapeState: bodyStateA shapeState
		bodyOrigin: firstTransform bodyOrigin
		rotation: firstTransform rotation
		andShapeState: bodyStateB shapeState
		bodyOrigin: secondTransform bodyOrigin
		rotation: secondTransform rotation
]

{ #category : 'collision' }
CFPhysicsManifoldGenerator >> manifoldBetweenShapeState: shapeStateA transform: transformA andShapeState: shapeStateB transform: transformB [
	^ self
		manifoldBetweenShapeState: shapeStateA
		bodyOrigin: transformA bodyOrigin
		rotation: transformA rotation
		andShapeState: shapeStateB
		bodyOrigin: transformB bodyOrigin
		rotation: transformB rotation
]

{ #category : 'private - collision' }
CFPhysicsManifoldGenerator >> manifoldBetweenShapeState: shapeStateA bodyOrigin: bodyOriginA rotation: rotationA andShapeState: shapeStateB bodyOrigin: bodyOriginB rotation: rotationB [
	(shapeStateA isCircle and: [ shapeStateB isCircle ]) ifTrue: [
		^ CFPhysicsCircleManifoldBuilder
			manifoldBetweenCircleShapeState: shapeStateA
			bodyOrigin: bodyOriginA
			rotation: rotationA
			andCircleShapeState: shapeStateB
			bodyOrigin: bodyOriginB
			rotation: rotationB ].
	shapeStateA isCircle ifTrue: [
		^ CFPhysicsCircleManifoldBuilder
			manifoldBetweenCircleShapeState: shapeStateA
			bodyOrigin: bodyOriginA
			rotation: rotationA
			andPolygonShapeState: shapeStateB
			bodyOrigin: bodyOriginB
			rotation: rotationB ].
	shapeStateB isCircle ifTrue: [
		^ CFPhysicsCircleManifoldBuilder
			manifoldBetweenPolygonShapeState: shapeStateA
			bodyOrigin: bodyOriginA
			rotation: rotationA
			andCircleShapeState: shapeStateB
			bodyOrigin: bodyOriginB
			rotation: rotationB ].
	^ self
		manifoldBetweenPolygonShapeState: shapeStateA
		bodyOrigin: bodyOriginA
		rotation: rotationA
		andPolygonShapeState: shapeStateB
		bodyOrigin: bodyOriginB
		rotation: rotationB
]

{ #category : 'private - collision' }
CFPhysicsManifoldGenerator >> manifoldBetweenPolygonShapeState: shapeStateA bodyOrigin: bodyOriginA rotation: rotationA andPolygonShapeState: shapeStateB bodyOrigin: bodyOriginB rotation: rotationB [
	| shapeA shapeB |
	shapeA := shapeStateA polygonShape.
	shapeB := shapeStateB polygonShape.
	(shapeA isNil or: [ shapeB isNil ]) ifTrue: [ ^ nil ].
	^ CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: shapeA
		bodyOrigin: bodyOriginA
		rotation: rotationA
		andShape: shapeB
		bodyOrigin: bodyOriginB
		rotation: rotationB
]
