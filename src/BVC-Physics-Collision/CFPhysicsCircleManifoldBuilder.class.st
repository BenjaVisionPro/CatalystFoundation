Class {
	#name : 'CFPhysicsCircleManifoldBuilder',
	#superclass : 'Object',
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'collision' }
CFPhysicsCircleManifoldBuilder class >> manifoldBetweenCircleShapeState: circleA bodyOrigin: bodyOriginA rotation: rotationA andCircleShapeState: circleB bodyOrigin: bodyOriginB rotation: rotationB [
	| delta distance radiusSum normal separation worldPoint point |
	delta := bodyOriginB - bodyOriginA.
	distance := delta r.
	radiusSum := circleA radius + circleB radius.
	distance > radiusSum ifTrue: [ ^ nil ].
	normal := distance = 0.0 ifTrue: [ 1 @ 0 ] ifFalse: [ delta / distance ].
	separation := distance - radiusSum.
	worldPoint := bodyOriginA + (normal * (circleA radius + (separation / 2.0))).
	point := CFPhysicsManifoldPoint at: worldPoint.
	point
		separation: separation;
		featureId: (CFPhysicsContactFeatureId
			featureA: #circle index: 1
			featureB: #circle index: 1);
		localAnchorA: (circleA localPointForWorldPoint: worldPoint bodyOrigin: bodyOriginA rotation: rotationA);
		localAnchorB: (circleB localPointForWorldPoint: worldPoint bodyOrigin: bodyOriginB rotation: rotationB).
	^ (CFPhysicsManifold normal: normal penetration: separation negated)
		contactPoints: { point };
		yourself
]

{ #category : 'collision' }
CFPhysicsCircleManifoldBuilder class >> manifoldBetweenCircleShapeState: circle bodyOrigin: circleBodyOrigin rotation: circleRotation andPolygonShapeState: polygonState bodyOrigin: polygonBodyOrigin rotation: polygonRotation [
	| polygon centre vertices normals radiusSum faceIndex faceSeparation faceNormal vertex1 vertex2 edge u1 u2 closest delta distance normal separation worldPoint point polygonFeatureKind polygonFeatureIndex |
	polygon := polygonState polygonShape.
	polygon ifNil: [ ^ nil ].
	centre := circleBodyOrigin.
	vertices := polygon worldVerticesAtBodyOrigin: polygonBodyOrigin rotation: polygonRotation.
	normals := polygon worldNormalsAtRotation: polygonRotation.
	radiusSum := circle radius + polygon radius.
	faceIndex := 1.
	faceSeparation := self dot: centre - vertices first with: normals first.
	2 to: vertices size do: [ :index |
		| candidate |
		candidate := self dot: centre - (vertices at: index) with: (normals at: index).
		candidate > faceSeparation ifTrue: [
			faceSeparation := candidate.
			faceIndex := index ] ].
	faceSeparation > radiusSum ifTrue: [ ^ nil ].
	faceNormal := normals at: faceIndex.
	vertex1 := vertices at: faceIndex.
	vertex2 := vertices at: (faceIndex = vertices size ifTrue: [ 1 ] ifFalse: [ faceIndex + 1 ]).
	edge := vertex2 - vertex1.
	u1 := self dot: centre - vertex1 with: edge.
	u2 := self dot: centre - vertex2 with: edge negated.
	(u1 <= 0.0 and: [ faceSeparation > 0.0 ])
		ifTrue: [
			closest := vertex1.
			polygonFeatureKind := #vertex.
			polygonFeatureIndex := faceIndex ]
		ifFalse: [
			(u2 <= 0.0 and: [ faceSeparation > 0.0 ])
				ifTrue: [
					closest := vertex2.
					polygonFeatureKind := #vertex.
					polygonFeatureIndex := faceIndex = vertices size ifTrue: [ 1 ] ifFalse: [ faceIndex + 1 ] ]
				ifFalse: [
					closest := centre - (faceNormal * faceSeparation).
					polygonFeatureKind := #face.
					polygonFeatureIndex := faceIndex ] ].
	delta := closest - centre.
	distance := delta r.
	separation := distance - radiusSum.
	separation > 0.0 ifTrue: [ ^ nil ].
	normal := polygonFeatureKind = #face
		ifTrue: [ faceNormal negated ]
		ifFalse: [ distance = 0.0 ifTrue: [ faceNormal negated ] ifFalse: [ delta / distance ] ].
	worldPoint := centre + (normal * (circle radius + (separation / 2.0))).
	point := CFPhysicsManifoldPoint at: worldPoint.
	point
		separation: separation;
		featureId: (CFPhysicsContactFeatureId
			featureA: #circle index: 1
			featureB: polygonFeatureKind index: polygonFeatureIndex);
		localAnchorA: (circle localPointForWorldPoint: worldPoint bodyOrigin: circleBodyOrigin rotation: circleRotation);
		localAnchorB: (polygonState localPointForWorldPoint: worldPoint bodyOrigin: polygonBodyOrigin rotation: polygonRotation).
	^ (CFPhysicsManifold normal: normal penetration: separation negated)
		contactPoints: { point };
		yourself
]

{ #category : 'collision' }
CFPhysicsCircleManifoldBuilder class >> manifoldBetweenPolygonShapeState: polygonState bodyOrigin: polygonBodyOrigin rotation: polygonRotation andCircleShapeState: circle bodyOrigin: circleBodyOrigin rotation: circleRotation [
	| manifold point oldFeature |
	manifold := self
		manifoldBetweenCircleShapeState: circle
		bodyOrigin: circleBodyOrigin
		rotation: circleRotation
		andPolygonShapeState: polygonState
		bodyOrigin: polygonBodyOrigin
		rotation: polygonRotation.
	manifold ifNil: [ ^ nil ].
	manifold normal: manifold normal negated.
	point := manifold contactPoints first.
	oldFeature := point featureId.
	point
		featureId: (CFPhysicsContactFeatureId
			featureA: oldFeature featureB index: oldFeature indexB
			featureB: oldFeature featureA index: oldFeature indexA);
		localAnchorA: (polygonState localPointForWorldPoint: point position bodyOrigin: polygonBodyOrigin rotation: polygonRotation);
		localAnchorB: (circle localPointForWorldPoint: point position bodyOrigin: circleBodyOrigin rotation: circleRotation).
	^ manifold
]

{ #category : 'private' }
CFPhysicsCircleManifoldBuilder class >> dot: first with: second [
	^ (first x * second x) + (first y * second y)
]
