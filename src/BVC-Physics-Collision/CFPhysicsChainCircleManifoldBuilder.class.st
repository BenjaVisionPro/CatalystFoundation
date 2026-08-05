"
I build Box2D-shaped one-sided contact manifolds between chain segments and circles.

The chain segment is shape A. Its directed edge collides only on its right side. Ghost vertices reject vertex contacts that belong to adjacent segments.
"
Class {
	#name : 'CFPhysicsChainCircleManifoldBuilder',
	#superclass : 'Object',
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'collision' }
CFPhysicsChainCircleManifoldBuilder class >> manifoldBetweenChainSegment: segment bodyOrigin: segmentBodyOrigin rotation: segmentRotation andCircleShapeState: circle bodyOrigin: circleBodyOrigin rotation: circleRotation speculativeDistance: speculativeDistance [
	| ghost1 point1 point2 ghost2 centre edge edgeLength normal offset u v closest featureKind featureIndex delta distance separation worldPoint point previousEdge nextEdge |
	ghost1 := segment worldGhost1AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	point1 := segment worldPoint1AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	point2 := segment worldPoint2AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	ghost2 := segment worldGhost2AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	centre := circleBodyOrigin.
	edge := point2 - point1.
	edgeLength := edge r.
	edgeLength = 0.0 ifTrue: [ ^ nil ].
	normal := edge y @ edge x negated / edgeLength.
	offset := self dot: centre - point1 with: normal.
	offset < 0.0 ifTrue: [ ^ nil ].
	u := self dot: edge with: point2 - centre.
	v := self dot: edge with: centre - point1.
	v <= 0.0
		ifTrue: [
			previousEdge := point1 - ghost1.
			(self dot: previousEdge with: centre - point1) <= 0.0 ifTrue: [ ^ nil ].
			closest := point1.
			featureKind := #vertex.
			featureIndex := 1 ]
		ifFalse: [
			u <= 0.0
				ifTrue: [
					nextEdge := ghost2 - point2.
					(self dot: nextEdge with: centre - point2) >= 0.0 ifTrue: [ ^ nil ].
					closest := point2.
					featureKind := #vertex.
					featureIndex := 2 ]
				ifFalse: [
					closest := point1 + (edge * (v / (u + v))).
					featureKind := #face.
					featureIndex := segment segmentIndex ] ].
	delta := centre - closest.
	distance := delta r.
	separation := distance - circle radius.
	separation > speculativeDistance ifTrue: [ ^ nil ].
	normal := distance = 0.0 ifTrue: [ normal ] ifFalse: [ delta / distance ].
	worldPoint := closest + (normal * (separation / 2.0)).
	point := CFPhysicsManifoldPoint at: worldPoint.
	point
		separation: separation;
		featureId: (CFPhysicsContactFeatureId
			featureA: featureKind index: featureIndex
			featureB: #circle index: 1);
		localAnchorA: (segment localPointForWorldPoint: worldPoint bodyOrigin: segmentBodyOrigin rotation: segmentRotation);
		localAnchorB: (circle localPointForWorldPoint: worldPoint bodyOrigin: circleBodyOrigin rotation: circleRotation).
	^ (CFPhysicsManifold normal: normal penetration: separation negated)
		contactPoints: { point };
		yourself
]

{ #category : 'collision' }
CFPhysicsChainCircleManifoldBuilder class >> manifoldBetweenCircleShapeState: circle bodyOrigin: circleBodyOrigin rotation: circleRotation andChainSegment: segment bodyOrigin: segmentBodyOrigin rotation: segmentRotation speculativeDistance: speculativeDistance [
	| manifold point oldFeature |
	manifold := self
		manifoldBetweenChainSegment: segment
		bodyOrigin: segmentBodyOrigin
		rotation: segmentRotation
		andCircleShapeState: circle
		bodyOrigin: circleBodyOrigin
		rotation: circleRotation
		speculativeDistance: speculativeDistance.
	manifold ifNil: [ ^ nil ].
	manifold normal: manifold normal negated.
	point := manifold contactPoints first.
	oldFeature := point featureId.
	point
		featureId: (CFPhysicsContactFeatureId
			featureA: oldFeature featureB index: oldFeature indexB
			featureB: oldFeature featureA index: oldFeature indexA);
		localAnchorA: (circle localPointForWorldPoint: point position bodyOrigin: circleBodyOrigin rotation: circleRotation);
		localAnchorB: (segment localPointForWorldPoint: point position bodyOrigin: segmentBodyOrigin rotation: segmentRotation).
	^ manifold
]

{ #category : 'private' }
CFPhysicsChainCircleManifoldBuilder class >> dot: first with: second [
	^ (first x * second x) + (first y * second y)
]
