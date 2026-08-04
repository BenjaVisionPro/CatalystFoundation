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
	^ self
		manifoldBetweenBodyState: bodyStateA
		andBodyState: bodyStateB
		speculativeDistance: 0.0
]

{ #category : 'collision' }
CFPhysicsManifoldGenerator >> manifoldBetweenBodyState: bodyStateA andBodyState: bodyStateB speculativeDistance: speculativeDistance [
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
		speculativeDistance: speculativeDistance
]

{ #category : 'collision' }
CFPhysicsManifoldGenerator >> manifoldBetweenShapeState: shapeStateA transform: transformA andShapeState: shapeStateB transform: transformB [
	^ self
		manifoldBetweenShapeState: shapeStateA
		transform: transformA
		andShapeState: shapeStateB
		transform: transformB
		speculativeDistance: 0.0
]

{ #category : 'collision' }
CFPhysicsManifoldGenerator >> manifoldBetweenShapeState: shapeStateA transform: transformA andShapeState: shapeStateB transform: transformB speculativeDistance: speculativeDistance [
	^ self
		manifoldBetweenShapeState: shapeStateA
		bodyOrigin: transformA bodyOrigin
		rotation: transformA rotation
		andShapeState: shapeStateB
		bodyOrigin: transformB bodyOrigin
		rotation: transformB rotation
		speculativeDistance: speculativeDistance
]



{ #category : 'collision' }
CFPhysicsManifoldGenerator >> manifoldForPair: aPair bodyStates: bodyStates speculativeDistance: speculativeDistance [
	| firstState secondState firstTransform secondTransform firstShape secondShape |
	firstState := bodyStates at: aPair firstBody.
	secondState := bodyStates at: aPair secondBody.
	firstTransform := firstState currentTransform.
	secondTransform := secondState currentTransform.
	firstShape := aPair firstShape.
	secondShape := aPair secondShape.
	firstShape isChainSegment ifTrue: [
		secondShape isCircle ifTrue: [
			^ CFPhysicsChainCircleManifoldBuilder
				manifoldBetweenChainSegment: firstShape
				bodyOrigin: firstTransform bodyOrigin
				rotation: firstTransform rotation
				andCircleShapeState: secondShape
				bodyOrigin: secondTransform bodyOrigin
				rotation: secondTransform rotation
				speculativeDistance: speculativeDistance ].
		^ CFPhysicsChainPolygonManifoldBuilder
			manifoldBetweenChainSegment: firstShape
			bodyOrigin: firstTransform bodyOrigin
			rotation: firstTransform rotation
			andPolygonShapeState: secondShape
			bodyOrigin: secondTransform bodyOrigin
			rotation: secondTransform rotation
			speculativeDistance: speculativeDistance ].
	secondShape isChainSegment ifTrue: [
		firstShape isCircle ifTrue: [
			^ CFPhysicsChainCircleManifoldBuilder
				manifoldBetweenCircleShapeState: firstShape
				bodyOrigin: firstTransform bodyOrigin
				rotation: firstTransform rotation
				andChainSegment: secondShape
				bodyOrigin: secondTransform bodyOrigin
				rotation: secondTransform rotation
				speculativeDistance: speculativeDistance ].
		^ CFPhysicsChainPolygonManifoldBuilder
			manifoldBetweenPolygonShapeState: firstShape
			bodyOrigin: firstTransform bodyOrigin
			rotation: firstTransform rotation
			andChainSegment: secondShape
			bodyOrigin: secondTransform bodyOrigin
			rotation: secondTransform rotation
			speculativeDistance: speculativeDistance ].
	^ self
		manifoldBetweenShapeState: firstShape
		bodyOrigin: firstTransform bodyOrigin
		rotation: firstTransform rotation
		andShapeState: secondShape
		bodyOrigin: secondTransform bodyOrigin
		rotation: secondTransform rotation
		speculativeDistance: speculativeDistance
]
{ #category : 'private - collision' }
CFPhysicsManifoldGenerator >> manifoldBetweenShapeState: shapeStateA bodyOrigin: bodyOriginA rotation: rotationA andShapeState: shapeStateB bodyOrigin: bodyOriginB rotation: rotationB [
	^ self
		manifoldBetweenShapeState: shapeStateA
		bodyOrigin: bodyOriginA
		rotation: rotationA
		andShapeState: shapeStateB
		bodyOrigin: bodyOriginB
		rotation: rotationB
		speculativeDistance: 0.0
]

{ #category : 'private - collision' }
CFPhysicsManifoldGenerator >> manifoldBetweenShapeState: shapeStateA bodyOrigin: bodyOriginA rotation: rotationA andShapeState: shapeStateB bodyOrigin: bodyOriginB rotation: rotationB speculativeDistance: speculativeDistance [
	(shapeStateA isCircle and: [ shapeStateB isCircle ]) ifTrue: [
		^ CFPhysicsCircleManifoldBuilder
			manifoldBetweenCircleShapeState: shapeStateA
			bodyOrigin: bodyOriginA
			rotation: rotationA
			andCircleShapeState: shapeStateB
			bodyOrigin: bodyOriginB
			rotation: rotationB
			speculativeDistance: speculativeDistance ].
	shapeStateA isCircle ifTrue: [
		^ CFPhysicsCircleManifoldBuilder
			manifoldBetweenCircleShapeState: shapeStateA
			bodyOrigin: bodyOriginA
			rotation: rotationA
			andPolygonShapeState: shapeStateB
			bodyOrigin: bodyOriginB
			rotation: rotationB
			speculativeDistance: speculativeDistance ].
	shapeStateB isCircle ifTrue: [
		^ CFPhysicsCircleManifoldBuilder
			manifoldBetweenPolygonShapeState: shapeStateA
			bodyOrigin: bodyOriginA
			rotation: rotationA
			andCircleShapeState: shapeStateB
			bodyOrigin: bodyOriginB
			rotation: rotationB
			speculativeDistance: speculativeDistance ].
	^ self
		manifoldBetweenPolygonShapeState: shapeStateA
		bodyOrigin: bodyOriginA
		rotation: rotationA
		andPolygonShapeState: shapeStateB
		bodyOrigin: bodyOriginB
		rotation: rotationB
		speculativeDistance: speculativeDistance
]

{ #category : 'private - collision' }
CFPhysicsManifoldGenerator >> manifoldBetweenPolygonShapeState: shapeStateA bodyOrigin: bodyOriginA rotation: rotationA andPolygonShapeState: shapeStateB bodyOrigin: bodyOriginB rotation: rotationB speculativeDistance: speculativeDistance [
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
		speculativeDistance: speculativeDistance
]
