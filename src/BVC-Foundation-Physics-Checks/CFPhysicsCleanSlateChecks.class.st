Class {
	#name : 'CFPhysicsCleanSlateChecks',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Checks',
	#package : 'BVC-Foundation-Physics-Checks'
}

{ #category : 'examples - step' }
CFPhysicsCleanSlateChecks >> softStepUsesSubstepDuration [
	<gtExample>
	| step |
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	self assert: (step substepTime closeTo: 0.004).
	self assert: (step inverseSubstepTime closeTo: 250.0).
	self assert: step massCoefficient > 0.0.
	self assert: step impulseCoefficient > 0.0.
	^ step
]

{ #category : 'examples - contacts' }
CFPhysicsCleanSlateChecks >> contactFeatureIdentityIsStructural [
	<gtExample>
	| first second different |
	first := CFPhysicsContactFeatureId
		featureA: #face index: 2 featureB: #vertex index: 1.
	second := CFPhysicsContactFeatureId
		featureA: #face index: 2 featureB: #vertex index: 1.
	different := CFPhysicsContactFeatureId
		featureA: #face index: 3 featureB: #vertex index: 1.
	self assert: first equals: second.
	self assert: first hash equals: second hash.
	self deny: first = different.
	^ first
]

{ #category : 'examples - contacts' }
CFPhysicsCleanSlateChecks >> manifoldPreservesImpulsesByFeatureIdentity [
	<gtExample>
	| retainedId oldPoint oldManifold retainedPoint newPoint newManifold |
	retainedId := CFPhysicsContactFeatureId
		featureA: #face index: 0 featureB: #vertex index: 1.
	oldPoint := CFPhysicsManifoldPoint at: 10 @ 20.
	oldPoint
		featureId: retainedId;
		normalImpulse: 7.5;
		tangentImpulse: -1.25.
	oldManifold := CFPhysicsManifold new contactPoints: { oldPoint }; yourself.

	retainedPoint := CFPhysicsManifoldPoint at: 11 @ 20.
	retainedPoint featureId: retainedId.
	newPoint := CFPhysicsManifoldPoint at: 30 @ 20.
	newPoint featureId: (CFPhysicsContactFeatureId
		featureA: #face index: 0 featureB: #vertex index: 2).
	newManifold := CFPhysicsManifold new
		contactPoints: { retainedPoint. newPoint };
		preserveImpulsesFrom: oldManifold;
		yourself.

	self assert: retainedPoint normalImpulse equals: 7.5.
	self assert: retainedPoint tangentImpulse equals: -1.25.
	self assert: newPoint normalImpulse equals: 0.0.
	self assert: newPoint tangentImpulse equals: 0.0.
	^ newManifold
]

{ #category : 'examples - contacts' }
CFPhysicsCleanSlateChecks >> manifoldDoesNotUsePositionAsIdentity [
	<gtExample>
	| oldPoint oldManifold newPoint newManifold |
	oldPoint := CFPhysicsManifoldPoint at: 10 @ 20.
	oldPoint
		featureId: (CFPhysicsContactFeatureId
			featureA: #face index: 0 featureB: #vertex index: 0);
		normalImpulse: 4.0.
	oldManifold := CFPhysicsManifold new contactPoints: { oldPoint }; yourself.

	newPoint := CFPhysicsManifoldPoint at: 10 @ 20.
	newPoint featureId: (CFPhysicsContactFeatureId
		featureA: #face index: 1 featureB: #vertex index: 0).
	newManifold := CFPhysicsManifold new
		contactPoints: { newPoint };
		preserveImpulsesFrom: oldManifold;
		yourself.

	self assert: newPoint normalImpulse equals: 0.0.
	^ newManifold
]

{ #category : 'examples - polygon manifolds' }
CFPhysicsCleanSlateChecks >> faceContactProducesTwoPoints [
	<gtExample>
	| ground box manifold |
	ground := CFPhysicsPolygonShape rectangleExtent: 100 @ 20.
	box := CFPhysicsPolygonShape rectangleExtent: 60 @ 20.
	manifold := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: ground position: 0 @ 0 rotation: 0
		andShape: box position: 20 @ 15 rotation: 0.
	self assert: manifold notNil.
	self assert: manifold contactPoints size equals: 2.
	self assert: manifold normal equals: 0 @ 1.
	manifold contactPoints do: [ :point |
		self assert: (point separation closeTo: -5.0).
		self assert: point featureId notNil.
		self assert: point localAnchorA notNil.
		self assert: point localAnchorB notNil ].
	^ manifold
]

{ #category : 'examples - polygon manifolds' }
CFPhysicsCleanSlateChecks >> faceContactIdentityPersistsAcrossTangentialMotion [
	<gtExample>
	| ground box first second firstIds secondIds |
	ground := CFPhysicsPolygonShape rectangleExtent: 100 @ 20.
	box := CFPhysicsPolygonShape rectangleExtent: 60 @ 20.
	first := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: ground position: 0 @ 0 rotation: 0
		andShape: box position: 20 @ 15 rotation: 0.
	second := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: ground position: 0 @ 0 rotation: 0
		andShape: box position: 21 @ 15 rotation: 0.
	firstIds := first contactPoints collect: [ :point | point featureId ].
	secondIds := second contactPoints collect: [ :point | point featureId ].
	self assert: firstIds asSet equals: secondIds asSet.
	^ second
]

{ #category : 'examples - polygon manifolds' }
CFPhysicsCleanSlateChecks >> roundedPolygonUsesCoreAndRadius [
	<gtExample>
	| ground box manifold |
	ground := CFPhysicsPolygonShape rectangleExtent: 100 @ 20 radius: 5.
	box := CFPhysicsPolygonShape rectangleExtent: 60 @ 20 radius: 5.
	manifold := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: ground position: 0 @ 0 rotation: 0
		andShape: box position: 20 @ 15 rotation: 0.
	self assert: manifold notNil.
	self assert: manifold contactPoints size equals: 2.
	manifold contactPoints do: [ :point |
		self assert: (point separation closeTo: -5.0) ].
	^ manifold
]

{ #category : 'examples - polygon manifolds' }
CFPhysicsCleanSlateChecks >> separatedPolygonCoresRespectCombinedRadius [
	<gtExample>
	| first second touching separated |
	first := CFPhysicsPolygonShape rectangleExtent: 100 @ 20 radius: 5.
	second := CFPhysicsPolygonShape rectangleExtent: 60 @ 20 radius: 5.
	touching := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: first position: 0 @ 0 rotation: 0
		andShape: second position: 20 @ 20 rotation: 0.
	separated := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: first position: 0 @ 0 rotation: 0
		andShape: second position: 20 @ 21 rotation: 0.
	self assert: touching notNil.
	self assert: separated isNil.
	^ touching
]

{ #category : 'examples - Bloc geometry' }
CFPhysicsCleanSlateChecks >> rectangleElementProducesPolygonShape [
	<gtExample>
	| element shapeState polygon |
	element := BlElement new
		geometry: BlRoundedRectangleGeometry new;
		size: 80 @ 30;
		yourself.
	shapeState := CFPhysicsShapeState on: element.
	polygon := shapeState polygonShape.
	self assert: polygon notNil.
	self assert: polygon radius equals: 0.0.
	self assert: polygon vertices equals: { 0.0 @ 0.0. 80.0 @ 0.0. 80.0 @ 30.0. 0.0 @ 30.0 }.
	^ polygon
]

{ #category : 'examples - Bloc geometry' }
CFPhysicsCleanSlateChecks >> roundedRectangleElementProducesInsetCoreAndRadius [
	<gtExample>
	| element shapeState polygon |
	element := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadii: (BlCornerRadii radius: 6));
		size: 80 @ 30;
		yourself.
	shapeState := CFPhysicsShapeState on: element.
	polygon := shapeState polygonShape.
	self assert: polygon radius equals: 6.0.
	self assert: polygon vertices equals: { 6.0 @ 6.0. 74.0 @ 6.0. 74.0 @ 24.0. 6.0 @ 24.0 }.
	^ polygon
]

{ #category : 'examples - Bloc geometry' }
CFPhysicsCleanSlateChecks >> normalizedPolygonElementUsesItsRenderedExtent [
	<gtExample>
	| element shapeState polygon |
	element := BlElement new
		geometry: (BlNormalizedPolygonGeometry vertices: { 0 @ 0. 1 @ 0. 0.5 @ 1 });
		size: 80 @ 30;
		yourself.
	shapeState := CFPhysicsShapeState on: element.
	polygon := shapeState polygonShape.
	self assert: polygon vertices equals: { 0 @ 0. 80 @ 0. 40.0 @ 30 }.
	^ polygon
]

{ #category : 'examples - Bloc geometry' }
CFPhysicsCleanSlateChecks >> BlocGeometryRoutesToPolygonManifold [
	<gtExample>
	| ground box manifold |
	ground := CFPhysicsShapeState on: (BlElement new
		geometry: BlRoundedRectangleGeometry new;
		size: 100 @ 20;
		yourself).
	box := CFPhysicsShapeState on: (BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadii: (BlCornerRadii radius: 5));
		size: 60 @ 20;
		yourself).
	manifold := CFPhysicsBlocManifoldBuilder
		manifoldBetweenShapeState: ground position: 0 @ 0 rotation: 0
		andShapeState: box position: 20 @ 15 rotation: 0.
	self assert: manifold notNil.
	self assert: manifold contactPoints size equals: 2.
	self assert: manifold normal equals: 0 @ 1.
	^ manifold
]

{ #category : 'examples - Bloc geometry' }
CFPhysicsCleanSlateChecks >> circleDoesNotPretendToBeAPolygon [
	<gtExample>
	| element shapeState |
	element := BlElement new
		geometry: BlCircleGeometry new;
		size: 30 @ 30;
		yourself.
	shapeState := CFPhysicsShapeState on: element.
	self assert: shapeState polygonShape isNil.
	^ shapeState
]
