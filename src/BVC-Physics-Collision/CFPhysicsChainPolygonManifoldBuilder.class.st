"I build one-sided manifolds between a Box2D-style chain segment and a convex polygon.

The chain segment is shape A. I use its directed-edge right normal, reject the back side, clip polygon vertices to the solid edge, and use ghost-edge ownership at the segment endpoints."
Class {
	#name : 'CFPhysicsChainPolygonManifoldBuilder',
	#superclass : 'Object',
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'collision' }
CFPhysicsChainPolygonManifoldBuilder class >> manifoldBetweenChainSegment: segment bodyOrigin: segmentBodyOrigin rotation: segmentRotation andPolygonShapeState: polygonState bodyOrigin: polygonBodyOrigin rotation: polygonRotation speculativeDistance: speculativeDistance [
	| polygon ghost1 point1 point2 ghost2 vertices edge edgeLength tangent normal centroid frontOffset previousEdge nextEdge candidates points penetration |
	polygon := polygonState polygonShape.
	polygon ifNil: [ ^ nil ].
	ghost1 := segment worldGhost1AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	point1 := segment worldPoint1AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	point2 := segment worldPoint2AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	ghost2 := segment worldGhost2AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	vertices := polygon worldVerticesAtBodyOrigin: polygonBodyOrigin rotation: polygonRotation.
	edge := point2 - point1.
	edgeLength := edge r.
	edgeLength = 0.0 ifTrue: [ ^ nil ].
	tangent := edge / edgeLength.
	normal := edge y @ edge x negated / edgeLength.
	centroid := (vertices inject: 0 @ 0 into: [ :sum :each | sum + each ]) / vertices size.
	frontOffset := self dot: centroid - point1 with: normal.
	frontOffset < 0.0 ifTrue: [ ^ nil ].
	previousEdge := point1 - ghost1.
	nextEdge := ghost2 - point2.
	candidates := OrderedCollection new: 2.
	1 to: vertices size do: [ :index |
		| vertex along separation owned |
		vertex := vertices at: index.
		along := self dot: vertex - point1 with: tangent.
		separation := (self dot: vertex - point1 with: normal) - polygon radius.
		owned := true.
		along < 0.0 ifTrue: [
			owned := (self dot: previousEdge with: vertex - point1) > 0.0 ].
		along > edgeLength ifTrue: [
			owned := (self dot: nextEdge with: vertex - point2) < 0.0 ].
		(owned and: [ along >= polygon radius negated and: [ along <= edgeLength + polygon radius and: [ separation <= speculativeDistance ] ] ]) ifTrue: [
			candidates add: { vertex. separation. index } ] ].
	candidates isEmpty ifTrue: [ ^ nil ].
	candidates size > 2 ifTrue: [ candidates := candidates first: 2 ].
	points := candidates collect: [ :candidate |
		| vertex separation index worldPoint point |
		vertex := candidate first.
		separation := candidate second.
		index := candidate third.
		worldPoint := vertex - (normal * ((separation + polygon radius) / 2.0)).
		point := CFPhysicsManifoldPoint at: worldPoint.
		point
			separation: separation;
			featureId: (CFPhysicsContactFeatureId
				featureA: #face index: segment segmentIndex
				featureB: #vertex index: index);
			localAnchorA: (segment localPointForWorldPoint: worldPoint bodyOrigin: segmentBodyOrigin rotation: segmentRotation);
			localAnchorB: (polygonState localPointForWorldPoint: worldPoint bodyOrigin: polygonBodyOrigin rotation: polygonRotation).
		point ].
	penetration := (points collect: [ :each | each separation negated ]) max.
	^ (CFPhysicsManifold normal: normal penetration: penetration)
		contactPoints: points asArray;
		yourself
]

{ #category : 'collision' }
CFPhysicsChainPolygonManifoldBuilder class >> manifoldBetweenPolygonShapeState: polygonState bodyOrigin: polygonBodyOrigin rotation: polygonRotation andChainSegment: segment bodyOrigin: segmentBodyOrigin rotation: segmentRotation speculativeDistance: speculativeDistance [
	| manifold |
	manifold := self
		manifoldBetweenChainSegment: segment
		bodyOrigin: segmentBodyOrigin
		rotation: segmentRotation
		andPolygonShapeState: polygonState
		bodyOrigin: polygonBodyOrigin
		rotation: polygonRotation
		speculativeDistance: speculativeDistance.
	manifold ifNil: [ ^ nil ].
	manifold normal: manifold normal negated.
	manifold contactPoints do: [ :point |
		| anchor feature |
		anchor := point localAnchorA.
		point localAnchorA: point localAnchorB; localAnchorB: anchor.
		feature := point featureId.
		point featureId: (CFPhysicsContactFeatureId
			featureA: feature featureB index: feature indexB
			featureB: feature featureA index: feature indexA) ].
	^ manifold
]

{ #category : 'private' }
CFPhysicsChainPolygonManifoldBuilder class >> dot: first with: second [
	^ (first x * second x) + (first y * second y)
]
