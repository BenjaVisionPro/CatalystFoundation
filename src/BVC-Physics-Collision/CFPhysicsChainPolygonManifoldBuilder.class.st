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
	| polygon vertices normals centroid chainSeparation polygonSeparation |
	polygon := polygonState polygonShape.
	polygon ifNil: [ ^ nil ].
	vertices := polygon worldVerticesAtBodyOrigin: polygonBodyOrigin rotation: polygonRotation.
	vertices isEmpty ifTrue: [ ^ nil ].
	normals := polygon worldNormalsAtRotation: polygonRotation.
	centroid := (vertices inject: 0 @ 0 into: [ :sum :vertex | sum + vertex ]) / vertices size.
	(self
		polygonCentroid: centroid
		isBehindChainSegment: segment
		bodyOrigin: segmentBodyOrigin
		rotation: segmentRotation) ifTrue: [ ^ nil ].
	chainSeparation := self
		chainSeparationForVertices: vertices
		chainSegment: segment
		bodyOrigin: segmentBodyOrigin
		rotation: segmentRotation.
	polygonSeparation := self
		polygonSeparationForVertices: vertices
		normals: normals
		chainSegment: segment
		bodyOrigin: segmentBodyOrigin
		rotation: segmentRotation.
	((polygonSeparation first notNil)
		and: [ polygonSeparation second > chainSeparation second ]) ifTrue: [
		^ self
			polygonReferenceManifoldFor: polygonSeparation first
			polygon: polygon
			vertices: vertices
			normals: normals
			segment: segment
			segmentBodyOrigin: segmentBodyOrigin
			segmentRotation: segmentRotation
			polygonState: polygonState
			polygonBodyOrigin: polygonBodyOrigin
			polygonRotation: polygonRotation
			speculativeDistance: speculativeDistance ].
	chainSeparation first ifNil: [ ^ nil ].
	^ self
		chainReferenceManifoldFor: chainSeparation first
		polygon: polygon
		vertices: vertices
		normals: normals
		segment: segment
		segmentBodyOrigin: segmentBodyOrigin
		segmentRotation: segmentRotation
		polygonState: polygonState
		polygonBodyOrigin: polygonBodyOrigin
		polygonRotation: polygonRotation
		speculativeDistance: speculativeDistance
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
	self reverse: manifold.
	^ manifold
]

{ #category : 'private - classification' }
CFPhysicsChainPolygonManifoldBuilder class >> polygonCentroid: centroid isBehindChainSegment: segment bodyOrigin: bodyOrigin rotation: rotation [
	| ghost1 point1 point2 ghost2 edge0 edge1 edge2 normal0 normal1 normal2 convex1 convex2 |
	ghost1 := segment worldGhost1AtBodyOrigin: bodyOrigin rotation: rotation.
	point1 := segment worldPoint1AtBodyOrigin: bodyOrigin rotation: rotation.
	point2 := segment worldPoint2AtBodyOrigin: bodyOrigin rotation: rotation.
	ghost2 := segment worldGhost2AtBodyOrigin: bodyOrigin rotation: rotation.
	edge0 := self unitVectorFrom: ghost1 to: point1.
	edge1 := self unitVectorFrom: point1 to: point2.
	edge2 := self unitVectorFrom: point2 to: ghost2.
	(edge0 isNil or: [ edge1 isNil or: [ edge2 isNil ] ]) ifTrue: [ ^ true ].
	normal0 := self rightPerpendicular: edge0.
	normal1 := self rightPerpendicular: edge1.
	normal2 := self rightPerpendicular: edge2.
	convex1 := (self cross: edge0 with: edge1) >= 0.01.
	convex2 := (self cross: edge1 with: edge2) >= 0.01.
	^ ((self dot: normal1 with: centroid - point1) < 0.0)
		and: [ (convex1 not or: [ (self dot: normal0 with: centroid - point1) < 0.0 ])
		and: [ convex2 not or: [ (self dot: normal2 with: centroid - point2) < 0.0 ] ] ]
]

{ #category : 'private - separation' }
CFPhysicsChainPolygonManifoldBuilder class >> chainSeparationForVertices: vertices chainSegment: segment bodyOrigin: bodyOrigin rotation: rotation [
	| ghost1 point1 point2 ghost2 edge0 edge1 edge2 normal0 normal1 normal2 incidentIndex edgeSeparation neighbourSeparation |
	ghost1 := segment worldGhost1AtBodyOrigin: bodyOrigin rotation: rotation.
	point1 := segment worldPoint1AtBodyOrigin: bodyOrigin rotation: rotation.
	point2 := segment worldPoint2AtBodyOrigin: bodyOrigin rotation: rotation.
	ghost2 := segment worldGhost2AtBodyOrigin: bodyOrigin rotation: rotation.
	edge0 := self unitVectorFrom: ghost1 to: point1.
	edge1 := self unitVectorFrom: point1 to: point2.
	edge2 := self unitVectorFrom: point2 to: ghost2.
	(edge0 isNil or: [ edge1 isNil or: [ edge2 isNil ] ]) ifTrue: [ ^ { nil. Float infinity } ].
	normal0 := self rightPerpendicular: edge0.
	normal1 := self rightPerpendicular: edge1.
	normal2 := self rightPerpendicular: edge2.
	incidentIndex := 1.
	edgeSeparation := Float infinity.
	1 to: vertices size do: [ :index |
		| separation |
		separation := self dot: normal1 with: (vertices at: index) - point1.
		separation < edgeSeparation ifTrue: [
			edgeSeparation := separation.
			incidentIndex := index ] ].
	(self cross: edge0 with: edge1) >= 0.01 ifTrue: [
		neighbourSeparation := self minimumSeparationOf: vertices along: normal0 from: point1.
		neighbourSeparation > edgeSeparation ifTrue: [
			edgeSeparation := neighbourSeparation.
			incidentIndex := nil ] ].
	(self cross: edge1 with: edge2) >= 0.01 ifTrue: [
		neighbourSeparation := self minimumSeparationOf: vertices along: normal2 from: point2.
		neighbourSeparation > edgeSeparation ifTrue: [
			edgeSeparation := neighbourSeparation.
			incidentIndex := nil ] ].
	^ { incidentIndex. edgeSeparation }
]

{ #category : 'private - separation' }
CFPhysicsChainPolygonManifoldBuilder class >> polygonSeparationForVertices: vertices normals: normals chainSegment: segment bodyOrigin: bodyOrigin rotation: rotation [
	| ghost1 point1 point2 ghost2 edge0 edge1 edge2 normal0 normal2 convex1 convex2 referenceIndex polygonSeparation |
	ghost1 := segment worldGhost1AtBodyOrigin: bodyOrigin rotation: rotation.
	point1 := segment worldPoint1AtBodyOrigin: bodyOrigin rotation: rotation.
	point2 := segment worldPoint2AtBodyOrigin: bodyOrigin rotation: rotation.
	ghost2 := segment worldGhost2AtBodyOrigin: bodyOrigin rotation: rotation.
	edge0 := self unitVectorFrom: ghost1 to: point1.
	edge1 := self unitVectorFrom: point1 to: point2.
	edge2 := self unitVectorFrom: point2 to: ghost2.
	(edge0 isNil or: [ edge1 isNil or: [ edge2 isNil ] ]) ifTrue: [ ^ { nil. Float negativeInfinity } ].
	normal0 := self rightPerpendicular: edge0.
	normal2 := self rightPerpendicular: edge2.
	convex1 := (self cross: edge0 with: edge1) >= 0.01.
	convex2 := (self cross: edge1 with: edge2) >= 0.01.
	referenceIndex := nil.
	polygonSeparation := Float negativeInfinity.
	1 to: normals size do: [ :index |
		| normal separation |
		normal := normals at: index.
		(self
			classifyNormal: normal negated
			edge: edge1
			normal0: normal0
			normal2: normal2
			convex1: convex1
			convex2: convex2) = #admit ifTrue: [
			separation :=
				(self dot: normal with: point1 - (vertices at: index))
					min: (self dot: normal with: point2 - (vertices at: index)).
			separation > polygonSeparation ifTrue: [
				polygonSeparation := separation.
				referenceIndex := index ] ] ].
	^ { referenceIndex. polygonSeparation }
]

{ #category : 'private - separation' }
CFPhysicsChainPolygonManifoldBuilder class >> minimumSeparationOf: vertices along: normal from: point [
	| separation |
	separation := Float infinity.
	vertices do: [ :vertex |
		separation := separation min: (self dot: normal with: vertex - point) ].
	^ separation
]

{ #category : 'private - manifold' }
CFPhysicsChainPolygonManifoldBuilder class >> chainReferenceManifoldFor: incidentIndex polygon: polygon vertices: vertices normals: normals segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation speculativeDistance: speculativeDistance [
	| point1 point2 edge normal incidentEdge clippedPoints points |
	point1 := segment worldPoint1AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	point2 := segment worldPoint2AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	edge := self unitVectorFrom: point1 to: point2.
	edge ifNil: [ ^ nil ].
	normal := self rightPerpendicular: edge.
	incidentEdge := self incidentEdgeForVertex: incidentIndex normals: normals withSegmentNormal: normal.
	clippedPoints := self
		clippedPointsForReferencePoint1: point1
		point2: point2
		incidentPoint1: (vertices at: incidentEdge first)
		incidentPoint2: (vertices at: incidentEdge second)
		normal: normal.
	clippedPoints isEmpty ifTrue: [ ^ nil ].
	points := OrderedCollection new: 2.
	self
		addClippedPoint: clippedPoints first
		feature: (CFPhysicsContactFeatureId
			featureA: #face index: segment segmentIndex
			featureB: #vertex index: incidentEdge second)
		referencePoint: point1 normal: normal
		referenceRadius: 0.0 incidentRadius: polygon radius
		segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation
		polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation
		speculativeDistance: speculativeDistance into: points.
	self
		addClippedPoint: clippedPoints second
		feature: (CFPhysicsContactFeatureId
			featureA: #face index: segment segmentIndex
			featureB: #vertex index: incidentEdge first)
		referencePoint: point1 normal: normal
		referenceRadius: 0.0 incidentRadius: polygon radius
		segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation
		polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation
		speculativeDistance: speculativeDistance into: points.
	^ self manifoldWithNormal: normal points: points
]

{ #category : 'private - manifold' }
CFPhysicsChainPolygonManifoldBuilder class >> polygonReferenceManifoldFor: referenceIndex polygon: polygon vertices: vertices normals: normals segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation speculativeDistance: speculativeDistance [
	| point1 point2 referencePoint1 referencePoint2 referenceNormal secondIndex clippedPoints points |
	point1 := segment worldPoint1AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	point2 := segment worldPoint2AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	secondIndex := referenceIndex = vertices size ifTrue: [ 1 ] ifFalse: [ referenceIndex + 1 ].
	referencePoint1 := vertices at: referenceIndex.
	referencePoint2 := vertices at: secondIndex.
	referenceNormal := normals at: referenceIndex.
	(self
		polygonReferenceNormal: referenceNormal
		referencePoint: referencePoint1
		segment: segment
		bodyOrigin: segmentBodyOrigin
		rotation: segmentRotation) ifFalse: [ ^ nil ].
	clippedPoints := self
		clippedPointsForReferencePoint1: referencePoint1
		point2: referencePoint2
		incidentPoint1: point1
		incidentPoint2: point2
		normal: referenceNormal.
	clippedPoints isEmpty ifTrue: [ ^ nil ].
	points := OrderedCollection new: 2.
	self
		addClippedPoint: clippedPoints first
		feature: (CFPhysicsContactFeatureId featureA: #vertex index: 1 featureB: #face index: referenceIndex)
		referencePoint: referencePoint1 normal: referenceNormal
		referenceRadius: polygon radius incidentRadius: 0.0
		segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation
		polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation
		speculativeDistance: speculativeDistance into: points.
	self
		addClippedPoint: clippedPoints second
		feature: (CFPhysicsContactFeatureId featureA: #vertex index: 2 featureB: #face index: secondIndex)
		referencePoint: referencePoint1 normal: referenceNormal
		referenceRadius: polygon radius incidentRadius: 0.0
		segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation
		polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation
		speculativeDistance: speculativeDistance into: points.
	^ self manifoldWithNormal: referenceNormal negated points: points
]

{ #category : 'private - manifold' }
CFPhysicsChainPolygonManifoldBuilder class >> polygonReferenceNormal: referenceNormal referencePoint: referencePoint segment: segment bodyOrigin: bodyOrigin rotation: rotation [
	| ghost1 point1 point2 ghost2 edge0 edge1 edge2 normal0 normal1 normal2 dot1 dot2 |
	ghost1 := segment worldGhost1AtBodyOrigin: bodyOrigin rotation: rotation.
	point1 := segment worldPoint1AtBodyOrigin: bodyOrigin rotation: rotation.
	point2 := segment worldPoint2AtBodyOrigin: bodyOrigin rotation: rotation.
	ghost2 := segment worldGhost2AtBodyOrigin: bodyOrigin rotation: rotation.
	edge0 := self unitVectorFrom: ghost1 to: point1.
	edge1 := self unitVectorFrom: point1 to: point2.
	edge2 := self unitVectorFrom: point2 to: ghost2.
	(edge0 isNil or: [ edge1 isNil or: [ edge2 isNil ] ]) ifTrue: [ ^ false ].
	normal0 := (self cross: edge0 with: edge1) >= 0.01
		ifTrue: [ self rightPerpendicular: edge0 ]
		ifFalse: [ self rightPerpendicular: edge1 ].
	normal1 := self rightPerpendicular: edge1.
	normal2 := (self cross: edge1 with: edge2) >= 0.01
		ifTrue: [ self rightPerpendicular: edge2 ]
		ifFalse: [ normal1 ].
	dot1 := self dot: referenceNormal with: point1 - referencePoint.
	dot2 := self dot: referenceNormal with: point2 - referencePoint.
	dot1 < dot2 ifTrue: [
		^ (self dot: normal0 with: referenceNormal) >= (self dot: normal1 with: referenceNormal) ].
	^ (self dot: normal2 with: referenceNormal) >= (self dot: normal1 with: referenceNormal)
]

{ #category : 'private - clipping' }
CFPhysicsChainPolygonManifoldBuilder class >> clippedPointsForReferencePoint1: referencePoint1 point2: referencePoint2 incidentPoint1: incidentPoint1 incidentPoint2: incidentPoint2 normal: normal [
	| tangent upper1 upper2 lower2 denominator lowerPoint upperPoint |
	tangent := self leftPerpendicular: normal.
	upper1 := self dot: referencePoint2 - referencePoint1 with: tangent.
	upper2 := self dot: incidentPoint1 - referencePoint1 with: tangent.
	lower2 := self dot: incidentPoint2 - referencePoint1 with: tangent.
	(upper2 < 0.0 or: [ upper1 < lower2 ]) ifTrue: [ ^ #() ].
	denominator := upper2 - lower2.
	lowerPoint := (lower2 < 0.0 and: [ denominator abs > Float epsilon ])
		ifTrue: [ incidentPoint2 + ((incidentPoint1 - incidentPoint2) * (lower2 negated / denominator)) ]
		ifFalse: [ incidentPoint2 ].
	upperPoint := (upper2 > upper1 and: [ denominator abs > Float epsilon ])
		ifTrue: [ incidentPoint2 + ((incidentPoint1 - incidentPoint2) * ((upper1 - lower2) / denominator)) ]
		ifFalse: [ incidentPoint1 ].
	^ { lowerPoint. upperPoint }
]

{ #category : 'private - manifold' }
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

{ #category : 'private - manifold' }
CFPhysicsChainPolygonManifoldBuilder class >> manifoldWithNormal: normal points: points [
	| penetration |
	points isEmpty ifTrue: [ ^ nil ].
	penetration := (points collect: [ :each | each separation negated ]) max.
	^ (CFPhysicsManifold normal: normal penetration: penetration)
		contactPoints: points asArray;
		yourself
]

{ #category : 'private - clipping' }
CFPhysicsChainPolygonManifoldBuilder class >> incidentEdgeForVertex: incidentIndex normals: normals withSegmentNormal: segmentNormal [
	| previousIndex firstDot secondDot |
	previousIndex := incidentIndex = 1 ifTrue: [ normals size ] ifFalse: [ incidentIndex - 1 ].
	firstDot := self dot: segmentNormal with: (normals at: previousIndex).
	secondDot := self dot: segmentNormal with: (normals at: incidentIndex).
	^ firstDot < secondDot
		ifTrue: [ { previousIndex. incidentIndex } ]
		ifFalse: [ { incidentIndex. incidentIndex = normals size ifTrue: [ 1 ] ifFalse: [ incidentIndex + 1 ] } ]
]

{ #category : 'private - classification' }
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

{ #category : 'private - orientation' }
CFPhysicsChainPolygonManifoldBuilder class >> reverse: manifold [
	manifold normal: manifold normal negated.
	manifold contactPoints do: [ :point |
		| anchor feature |
		anchor := point localAnchorA.
		point localAnchorA: point localAnchorB; localAnchorB: anchor.
		feature := point featureId.
		point featureId: (CFPhysicsContactFeatureId
			featureA: feature featureB index: feature indexB
			featureB: feature featureA index: feature indexA) ]
]

{ #category : 'private - geometry' }
CFPhysicsChainPolygonManifoldBuilder class >> unitVectorFrom: firstPoint to: secondPoint [
	| vector length |
	vector := secondPoint - firstPoint.
	length := vector r.
	length = 0.0 ifTrue: [ ^ nil ].
	^ vector / length
]

{ #category : 'private - geometry' }
CFPhysicsChainPolygonManifoldBuilder class >> rightPerpendicular: vector [
	^ vector y @ vector x negated
]

{ #category : 'private - geometry' }
CFPhysicsChainPolygonManifoldBuilder class >> leftPerpendicular: vector [
	^ vector y negated @ vector x
]

{ #category : 'private - geometry' }
CFPhysicsChainPolygonManifoldBuilder class >> cross: first with: second [
	^ (first x * second y) - (first y * second x)
]

{ #category : 'private - geometry' }
CFPhysicsChainPolygonManifoldBuilder class >> dot: first with: second [
	^ (first x * second x) + (first y * second y)
]
