"I build Box2D 3.1.1-style one-sided manifolds between a chain segment and a convex polygon.

The chain segment is shape A. I preserve Box2D's neighbour ownership, Gauss-map normal classification, SAT reference selection, segment clipping, speculative separation and feature identity."
Class {
	#name : 'CFPhysicsChainPolygonManifoldBuilder',
	#superclass : 'Object',
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'collision' }
CFPhysicsChainPolygonManifoldBuilder class >> manifoldBetweenChainSegment: segment bodyOrigin: segmentBodyOrigin rotation: segmentRotation andPolygonShapeState: polygonState bodyOrigin: polygonBodyOrigin rotation: polygonRotation speculativeDistance: speculativeDistance [
	| polygon ghost1 point1 point2 ghost2 vertices normals centroid edge0 edge1 edge2 normal0 normal1 normal2 convex1 convex2 behind0 behind1 behind2 incidentIndex edgeSeparation polygonSeparation referenceIndex incidentNormal points manifoldNormal penetration |
	polygon := polygonState polygonShape.
	polygon ifNil: [ ^ nil ].
	ghost1 := segment worldGhost1AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	point1 := segment worldPoint1AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	point2 := segment worldPoint2AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	ghost2 := segment worldGhost2AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	vertices := polygon worldVerticesAtBodyOrigin: polygonBodyOrigin rotation: polygonRotation.
	normals := polygon worldNormalsAtRotation: polygonRotation.
	vertices isEmpty ifTrue: [ ^ nil ].
	centroid := (vertices inject: 0 @ 0 into: [ :sum :each | sum + each ]) / vertices size.
	edge1 := self normalized: point2 - point1.
	edge1 ifNil: [ ^ nil ].
	edge0 := self normalized: point1 - ghost1.
	edge2 := self normalized: ghost2 - point2.
	(edge0 isNil or: [ edge2 isNil ]) ifTrue: [ ^ nil ].
	normal0 := self rightPerpendicular: edge0.
	normal1 := self rightPerpendicular: edge1.
	normal2 := self rightPerpendicular: edge2.
	convex1 := (self cross: edge0 with: edge1) >= 0.01.
	convex2 := (self cross: edge1 with: edge2) >= 0.01.
	behind1 := (self dot: normal1 with: centroid - point1) < 0.0.
	behind0 := convex1
		ifTrue: [ (self dot: normal0 with: centroid - point1) < 0.0 ]
		ifFalse: [ true ].
	behind2 := convex2
		ifTrue: [ (self dot: normal2 with: centroid - point2) < 0.0 ]
		ifFalse: [ true ].
	(behind1 and: [ behind0 and: [ behind2 ] ]) ifTrue: [ ^ nil ].

	incidentIndex := 1.
	edgeSeparation := Float infinity.
	1 to: vertices size do: [ :index |
		| separation |
		separation := self dot: normal1 with: (vertices at: index) - point1.
		separation < edgeSeparation ifTrue: [
			edgeSeparation := separation.
			incidentIndex := index ] ].

	convex1 ifTrue: [
		| neighbourSeparation |
		neighbourSeparation := Float infinity.
		vertices do: [ :vertex |
			neighbourSeparation := neighbourSeparation min: (self dot: normal0 with: vertex - point1) ].
		neighbourSeparation > edgeSeparation ifTrue: [
			edgeSeparation := neighbourSeparation.
			incidentIndex := nil ] ].
	convex2 ifTrue: [
		| neighbourSeparation |
		neighbourSeparation := Float infinity.
		vertices do: [ :vertex |
			neighbourSeparation := neighbourSeparation min: (self dot: normal2 with: vertex - point2) ].
		neighbourSeparation > edgeSeparation ifTrue: [
			edgeSeparation := neighbourSeparation.
			incidentIndex := nil ] ].

	polygonSeparation := Float negativeInfinity.
	referenceIndex := nil.
	1 to: normals size do: [ :index |
		| normal classification vertex separation |
		normal := normals at: index.
		classification := self
			classifyNormal: normal negated
			edge: edge1
			normal0: normal0
			normal2: normal2
			convex1: convex1
			convex2: convex2.
		classification = #admit ifTrue: [
			vertex := vertices at: index.
			separation :=
				(self dot: normal with: point1 - vertex)
					min: (self dot: normal with: point2 - vertex).
			separation > polygonSeparation ifTrue: [
				polygonSeparation := separation.
				referenceIndex := index ] ] ].

	(referenceIndex notNil and: [ polygonSeparation > edgeSeparation ]) ifTrue: [
		^ self
			polygonReferenceManifoldAt: referenceIndex
			vertices: vertices
			normals: normals
			point1: point1
			point2: point2
			normal0: (convex1 ifTrue: [ normal0 ] ifFalse: [ normal1 ])
			normal1: normal1
			normal2: (convex2 ifTrue: [ normal2 ] ifFalse: [ normal1 ])
			polygonRadius: polygon radius
			segment: segment
			segmentBodyOrigin: segmentBodyOrigin
			segmentRotation: segmentRotation
			polygonState: polygonState
			polygonBodyOrigin: polygonBodyOrigin
			polygonRotation: polygonRotation
			speculativeDistance: speculativeDistance ].

	incidentIndex ifNil: [ ^ nil ].
	incidentNormal := self
		incidentEdgeForVertex: incidentIndex
		normals: normals
		withSegmentNormal: normal1.
	points := self
		clipReferencePoint1: point1
		point2: point2
		incidentPoint1: (vertices at: incidentNormal first)
		incidentPoint2: (vertices at: incidentNormal second)
		normal: normal1
		referenceRadius: 0.0
		incidentRadius: polygon radius
		firstFeature: (CFPhysicsContactFeatureId
			featureA: #vertex index: 1
			featureB: #vertex index: incidentNormal second)
		secondFeature: (CFPhysicsContactFeatureId
			featureA: #vertex index: 2
			featureB: #vertex index: incidentNormal first)
		segment: segment
		segmentBodyOrigin: segmentBodyOrigin
		segmentRotation: segmentRotation
		polygonState: polygonState
		polygonBodyOrigin: polygonBodyOrigin
		polygonRotation: polygonRotation
		speculativeDistance: speculativeDistance.
	points isEmpty ifTrue: [ ^ nil ].
	manifoldNormal := normal1.
	penetration := (points collect: [ :each | each separation negated ]) max.
	^ (CFPhysicsManifold normal: manifoldNormal penetration: penetration)
		contactPoints: points;
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
CFPhysicsChainPolygonManifoldBuilder class >> polygonReferenceManifoldAt: referenceIndex vertices: vertices normals: normals point1: point1 point2: point2 normal0: normal0 normal1: normal1 normal2: normal2 polygonRadius: polygonRadius segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation speculativeDistance: speculativeDistance [
	| secondIndex referencePoint1 referencePoint2 referenceNormal dot1 dot2 points penetration |
	secondIndex := referenceIndex = vertices size ifTrue: [ 1 ] ifFalse: [ referenceIndex + 1 ].
	referencePoint1 := vertices at: referenceIndex.
	referencePoint2 := vertices at: secondIndex.
	referenceNormal := normals at: referenceIndex.
	dot1 := self dot: referenceNormal with: point1 - referencePoint1.
	dot2 := self dot: referenceNormal with: point2 - referencePoint1.
	dot1 < dot2
		ifTrue: [
			(self dot: normal0 with: referenceNormal) < (self dot: normal1 with: referenceNormal)
				ifTrue: [ ^ nil ] ]
		ifFalse: [
			(self dot: normal2 with: referenceNormal) < (self dot: normal1 with: referenceNormal)
				ifTrue: [ ^ nil ] ].
	points := self
		clipReferencePoint1: referencePoint1
		point2: referencePoint2
		incidentPoint1: point1
		incidentPoint2: point2
		normal: referenceNormal
		referenceRadius: polygonRadius
		incidentRadius: 0.0
		firstFeature: (CFPhysicsContactFeatureId
			featureA: #vertex index: 1
			featureB: #vertex index: referenceIndex)
		secondFeature: (CFPhysicsContactFeatureId
			featureA: #vertex index: 2
			featureB: #vertex index: secondIndex)
		segment: segment
		segmentBodyOrigin: segmentBodyOrigin
		segmentRotation: segmentRotation
		polygonState: polygonState
		polygonBodyOrigin: polygonBodyOrigin
		polygonRotation: polygonRotation
		speculativeDistance: speculativeDistance.
	points isEmpty ifTrue: [ ^ nil ].
	penetration := (points collect: [ :each | each separation negated ]) max.
	^ (CFPhysicsManifold normal: referenceNormal negated penetration: penetration)
		contactPoints: points;
		yourself
]

{ #category : 'private' }
CFPhysicsChainPolygonManifoldBuilder class >> clipReferencePoint1: referencePoint1 point2: referencePoint2 incidentPoint1: incidentPoint1 incidentPoint2: incidentPoint2 normal: normal referenceRadius: referenceRadius incidentRadius: incidentRadius firstFeature: firstFeature secondFeature: secondFeature segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation speculativeDistance: speculativeDistance [
	| tangent lower1 upper1 upper2 lower2 lowerPoint upperPoint denominator points |
	tangent := self leftPerpendicular: normal.
	lower1 := 0.0.
	upper1 := self dot: referencePoint2 - referencePoint1 with: tangent.
	upper2 := self dot: incidentPoint1 - referencePoint1 with: tangent.
	lower2 := self dot: incidentPoint2 - referencePoint1 with: tangent.
	(upper2 < lower1 or: [ upper1 < lower2 ]) ifTrue: [ ^ #() ].
	denominator := upper2 - lower2.
	lowerPoint := (lower2 < lower1 and: [ denominator abs > Float epsilon ])
		ifTrue: [ incidentPoint2 + ((incidentPoint1 - incidentPoint2) * ((lower1 - lower2) / denominator)) ]
		ifFalse: [ incidentPoint2 ].
	upperPoint := (upper2 > upper1 and: [ denominator abs > Float epsilon ])
		ifTrue: [ incidentPoint2 + ((incidentPoint1 - incidentPoint2) * ((upper1 - lower2) / denominator)) ]
		ifFalse: [ incidentPoint1 ].
	points := OrderedCollection new: 2.
	self
		addClippedPoint: lowerPoint
		feature: firstFeature
		referencePoint: referencePoint1
		normal: normal
		referenceRadius: referenceRadius
		incidentRadius: incidentRadius
		segment: segment
		segmentBodyOrigin: segmentBodyOrigin
		segmentRotation: segmentRotation
		polygonState: polygonState
		polygonBodyOrigin: polygonBodyOrigin
		polygonRotation: polygonRotation
		speculativeDistance: speculativeDistance
		into: points.
	self
		addClippedPoint: upperPoint
		feature: secondFeature
		referencePoint: referencePoint1
		normal: normal
		referenceRadius: referenceRadius
		incidentRadius: incidentRadius
		segment: segment
		segmentBodyOrigin: segmentBodyOrigin
		segmentRotation: segmentRotation
		polygonState: polygonState
		polygonBodyOrigin: polygonBodyOrigin
		polygonRotation: polygonRotation
		speculativeDistance: speculativeDistance
		into: points.
	^ points asArray
]

{ #category : 'private' }
CFPhysicsChainPolygonManifoldBuilder class >> addClippedPoint: incidentPoint feature: feature referencePoint: referencePoint normal: normal referenceRadius: referenceRadius incidentRadius: incidentRadius segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation speculativeDistance: speculativeDistance into: points [
	| coreSeparation separation worldPoint point |
	coreSeparation := self dot: incidentPoint - referencePoint with: normal.
	separation := coreSeparation - referenceRadius - incidentRadius.
	separation > speculativeDistance ifTrue: [ ^ self ].
	worldPoint := incidentPoint + (normal * (0.5 * (referenceRadius - incidentRadius - coreSeparation))).
	point := CFPhysicsManifoldPoint at: worldPoint.
	point
		separation: separation;
		featureId: feature;
		localAnchorA: (segment localPointForWorldPoint: worldPoint bodyOrigin: segmentBodyOrigin rotation: segmentRotation);
		localAnchorB: (polygonState localPointForWorldPoint: worldPoint bodyOrigin: polygonBodyOrigin rotation: polygonRotation).
	points add: point
]

{ #category : 'private' }
CFPhysicsChainPolygonManifoldBuilder class >> incidentEdgeForVertex: incidentIndex normals: normals withSegmentNormal: segmentNormal [
	| previousIndex firstDot secondDot |
	previousIndex := incidentIndex = 1 ifTrue: [ normals size ] ifFalse: [ incidentIndex - 1 ].
	firstDot := self dot: segmentNormal with: (normals at: previousIndex).
	secondDot := self dot: segmentNormal with: (normals at: incidentIndex).
	^ firstDot < secondDot
		ifTrue: [ { previousIndex. incidentIndex } ]
		ifFalse: [ { incidentIndex. incidentIndex = normals size ifTrue: [ 1 ] ifFalse: [ incidentIndex + 1 ] } ]
]

{ #category : 'private' }
CFPhysicsChainPolygonManifoldBuilder class >> classifyNormal: normal edge: edge normal0: normal0 normal2: normal2 convex1: convex1 convex2: convex2 [
	(self dot: normal with: edge) <= 0.0
		ifTrue: [
			convex1 ifFalse: [ ^ #snap ].
			(self cross: normal with: normal0) > 0.01 ifTrue: [ ^ #skip ].
			^ #admit ]
		ifFalse: [
			convex2 ifFalse: [ ^ #snap ].
			(self cross: normal2 with: normal) > 0.01 ifTrue: [ ^ #skip ].
			^ #admit ]
]

{ #category : 'private' }
CFPhysicsChainPolygonManifoldBuilder class >> normalized: vector [
	| length |
	length := vector r.
	length <= Float epsilon ifTrue: [ ^ nil ].
	^ vector / length
]

{ #category : 'private' }
CFPhysicsChainPolygonManifoldBuilder class >> rightPerpendicular: vector [
	^ vector y @ vector x negated
]

{ #category : 'private' }
CFPhysicsChainPolygonManifoldBuilder class >> leftPerpendicular: vector [
	^ vector y negated @ vector x
]

{ #category : 'private' }
CFPhysicsChainPolygonManifoldBuilder class >> cross: first with: second [
	^ (first x * second y) - (first y * second x)
]

{ #category : 'private' }
CFPhysicsChainPolygonManifoldBuilder class >> dot: first with: second [
	^ (first x * second x) + (first y * second y)
]
