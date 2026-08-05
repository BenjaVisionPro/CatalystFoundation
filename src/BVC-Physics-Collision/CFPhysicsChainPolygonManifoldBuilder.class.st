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
	| polygonGeometry chainGeometry chainSeparation polygonSeparation |
	polygonGeometry := self
		polygonGeometryFor: polygonState
		bodyOrigin: polygonBodyOrigin
		rotation: polygonRotation.
	polygonGeometry ifNil: [ ^ nil ].
	chainGeometry := self
		chainGeometryFor: segment
		bodyOrigin: segmentBodyOrigin
		rotation: segmentRotation.
	chainGeometry ifNil: [ ^ nil ].
	(self polygonGeometry: polygonGeometry isBehindChainGeometry: chainGeometry)
		ifTrue: [ ^ nil ].
	chainSeparation := self
		chainSeparationForPolygonGeometry: polygonGeometry
		chainGeometry: chainGeometry.
	polygonSeparation := self
		polygonSeparationForPolygonGeometry: polygonGeometry
		chainGeometry: chainGeometry.
	((polygonSeparation first notNil)
		and: [ polygonSeparation second > chainSeparation second ])
		ifTrue: [
			^ self
				polygonReferenceManifoldFor: polygonSeparation first
				polygonGeometry: polygonGeometry
				chainGeometry: chainGeometry
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
		polygonGeometry: polygonGeometry
		chainGeometry: chainGeometry
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

{ #category : 'private - geometry' }
CFPhysicsChainPolygonManifoldBuilder class >> polygonGeometryFor: polygonState bodyOrigin: bodyOrigin rotation: rotation [
	| polygon vertices normals centroid |
	polygon := polygonState polygonShape.
	polygon ifNil: [ ^ nil ].
	vertices := polygon worldVerticesAtBodyOrigin: bodyOrigin rotation: rotation.
	vertices isEmpty ifTrue: [ ^ nil ].
	normals := polygon worldNormalsAtRotation: rotation.
	centroid := (vertices inject: 0 @ 0 into: [ :sum :each | sum + each ]) / vertices size.
	^ { polygon. vertices. normals. centroid }
]

{ #category : 'private - geometry' }
CFPhysicsChainPolygonManifoldBuilder class >> chainGeometryFor: segment bodyOrigin: bodyOrigin rotation: rotation [
	| ghost1 point1 point2 ghost2 edge0 edge1 edge2 normal0 normal1 normal2 convex1 convex2 |
	ghost1 := segment worldGhost1AtBodyOrigin: bodyOrigin rotation: rotation.
	point1 := segment worldPoint1AtBodyOrigin: bodyOrigin rotation: rotation.
	point2 := segment worldPoint2AtBodyOrigin: bodyOrigin rotation: rotation.
	ghost2 := segment worldGhost2AtBodyOrigin: bodyOrigin rotation: rotation.
	edge0 := self normalized: point1 - ghost1.
	edge1 := self normalized: point2 - point1.
	edge2 := self normalized: ghost2 - point2.
	(edge0 isNil or: [ edge1 isNil or: [ edge2 isNil ] ]) ifTrue: [ ^ nil ].
	normal0 := self rightPerpendicular: edge0.
	normal1 := self rightPerpendicular: edge1.
	normal2 := self rightPerpendicular: edge2.
	convex1 := (self cross: edge0 with: edge1) >= 0.01.
	convex2 := (self cross: edge1 with: edge2) >= 0.01.
	^ { ghost1. point1. point2. ghost2. edge0. edge1. edge2. normal0. normal1. normal2. convex1. convex2 }
]

{ #category : 'private - classification' }
CFPhysicsChainPolygonManifoldBuilder class >> polygonGeometry: polygonGeometry isBehindChainGeometry: chainGeometry [
	| centroid point1 point2 normal0 normal1 normal2 convex1 convex2 behind0 behind1 behind2 |
	centroid := polygonGeometry fourth.
	point1 := chainGeometry second.
	point2 := chainGeometry third.
	normal0 := chainGeometry eighth.
	normal1 := chainGeometry ninth.
	normal2 := chainGeometry tenth.
	convex1 := chainGeometry eleventh.
	convex2 := chainGeometry twelfth.
	behind1 := (self dot: normal1 with: centroid - point1) < 0.0.
	behind0 := convex1
		ifTrue: [ (self dot: normal0 with: centroid - point1) < 0.0 ]
		ifFalse: [ true ].
	behind2 := convex2
		ifTrue: [ (self dot: normal2 with: centroid - point2) < 0.0 ]
		ifFalse: [ true ].
	^ behind1 and: [ behind0 and: [ behind2 ] ]
]

{ #category : 'private - separation' }
CFPhysicsChainPolygonManifoldBuilder class >> chainSeparationForPolygonGeometry: polygonGeometry chainGeometry: chainGeometry [
	| vertices point1 point2 normal0 normal1 normal2 convex1 convex2 incidentIndex edgeSeparation neighbourSeparation |
	vertices := polygonGeometry second.
	point1 := chainGeometry second.
	point2 := chainGeometry third.
	normal0 := chainGeometry eighth.
	normal1 := chainGeometry ninth.
	normal2 := chainGeometry tenth.
	convex1 := chainGeometry eleventh.
	convex2 := chainGeometry twelfth.
	incidentIndex := 1.
	edgeSeparation := Float infinity.
	1 to: vertices size do: [ :index |
		| separation |
		separation := self dot: normal1 with: (vertices at: index) - point1.
		separation < edgeSeparation ifTrue: [
			edgeSeparation := separation.
			incidentIndex := index ] ].
	convex1 ifTrue: [
		neighbourSeparation := self minimumSeparationOf: vertices along: normal0 from: point1.
		neighbourSeparation > edgeSeparation ifTrue: [
			edgeSeparation := neighbourSeparation.
			incidentIndex := nil ] ].
	convex2 ifTrue: [
		neighbourSeparation := self minimumSeparationOf: vertices along: normal2 from: point2.
		neighbourSeparation > edgeSeparation ifTrue: [
			edgeSeparation := neighbourSeparation.
			incidentIndex := nil ] ].
	^ { incidentIndex. edgeSeparation }
]

{ #category : 'private - separation' }
CFPhysicsChainPolygonManifoldBuilder class >> polygonSeparationForPolygonGeometry: polygonGeometry chainGeometry: chainGeometry [
	| vertices normals point1 point2 edge1 normal0 normal2 convex1 convex2 referenceIndex polygonSeparation |
	vertices := polygonGeometry second.
	normals := polygonGeometry third.
	point1 := chainGeometry second.
	point2 := chainGeometry third.
	edge1 := chainGeometry sixth.
	normal0 := chainGeometry eighth.
	normal2 := chainGeometry tenth.
	convex1 := chainGeometry eleventh.
	convex2 := chainGeometry twelfth.
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
CFPhysicsChainPolygonManifoldBuilder class >> chainReferenceManifoldFor: incidentIndex polygonGeometry: polygonGeometry chainGeometry: chainGeometry segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation speculativeDistance: speculativeDistance [
	| polygon vertices normals point1 normal1 incidentEdge clippedPoints points |
	polygon := polygonGeometry first.
	vertices := polygonGeometry second.
	normals := polygonGeometry third.
	point1 := chainGeometry second.
	normal1 := chainGeometry ninth.
	incidentEdge := self
		incidentEdgeForVertex: incidentIndex
		normals: normals
		withSegmentNormal: normal1.
	clippedPoints := self
		clippedPointsForReferencePoint1: point1
		point2: chainGeometry third
		incidentPoint1: (vertices at: incidentEdge first)
		incidentPoint2: (vertices at: incidentEdge second)
		normal: normal1.
	clippedPoints isEmpty ifTrue: [ ^ nil ].
	points := OrderedCollection new: 2.
	self
		addClippedPoint: clippedPoints first
		feature: (CFPhysicsContactFeatureId
			featureA: #face index: segment segmentIndex
			featureB: #vertex index: incidentEdge second)
		referencePoint: point1
		normal: normal1
		referenceRadius: 0.0
		incidentRadius: polygon radius
		segment: segment
		segmentBodyOrigin: segmentBodyOrigin
		segmentRotation: segmentRotation
		polygonState: polygonState
		polygonBodyOrigin: polygonBodyOrigin
		polygonRotation: polygonRotation
		speculativeDistance: speculativeDistance
		into: points.
	self
		addClippedPoint: clippedPoints second
		feature: (CFPhysicsContactFeatureId
			featureA: #face index: segment segmentIndex
			featureB: #vertex index: incidentEdge first)
		referencePoint: point1
		normal: normal1
		referenceRadius: 0.0
		incidentRadius: polygon radius
		segment: segment
		segmentBodyOrigin: segmentBodyOrigin
		segmentRotation: segmentRotation
		polygonState: polygonState
		polygonBodyOrigin: polygonBodyOrigin
		polygonRotation: polygonRotation
		speculativeDistance: speculativeDistance
		into: points.
	^ self manifoldWithNormal: normal1 points: points
]

{ #category : 'private - manifold' }
CFPhysicsChainPolygonManifoldBuilder class >> polygonReferenceManifoldFor: referenceIndex polygonGeometry: polygonGeometry chainGeometry: chainGeometry segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation speculativeDistance: speculativeDistance [
	| polygon vertices normals point1 point2 normal0 normal1 normal2 secondIndex referencePoint1 referencePoint2 referenceNormal clippedPoints points |
	polygon := polygonGeometry first.
	vertices := polygonGeometry second.
	normals := polygonGeometry third.
	point1 := chainGeometry second.
	point2 := chainGeometry third.
	normal0 := chainGeometry eleventh ifTrue: [ chainGeometry eighth ] ifFalse: [ chainGeometry ninth ].
	normal1 := chainGeometry ninth.
	normal2 := chainGeometry twelfth ifTrue: [ chainGeometry tenth ] ifFalse: [ chainGeometry ninth ].
	secondIndex := referenceIndex = vertices size ifTrue: [ 1 ] ifFalse: [ referenceIndex + 1 ].
	referencePoint1 := vertices at: referenceIndex.
	referencePoint2 := vertices at: secondIndex.
	referenceNormal := normals at: referenceIndex.
	(self
		polygonReferenceNormal: referenceNormal
		referencePoint: referencePoint1
		point1: point1
		point2: point2
		normal0: normal0
		normal1: normal1
		normal2: normal2) ifFalse: [ ^ nil ].
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
		feature: (CFPhysicsContactFeatureId
			featureA: #vertex index: 1
			featureB: #face index: referenceIndex)
		referencePoint: referencePoint1
		normal: referenceNormal
		referenceRadius: polygon radius
		incidentRadius: 0.0
		segment: segment
		segmentBodyOrigin: segmentBodyOrigin
		segmentRotation: segmentRotation
		polygonState: polygonState
		polygonBodyOrigin: polygonBodyOrigin
		polygonRotation: polygonRotation
		speculativeDistance: speculativeDistance
		into: points.
	self
		addClippedPoint: clippedPoints second
		feature: (CFPhysicsContactFeatureId
			featureA: #vertex index: 2
			featureB: #face index: secondIndex)
		referencePoint: referencePoint1
		normal: referenceNormal
		referenceRadius: polygon radius
		incidentRadius: 0.0
		segment: segment
		segmentBodyOrigin: segmentBodyOrigin
		segmentRotation: segmentRotation
		polygonState: polygonState
		polygonBodyOrigin: polygonBodyOrigin
		polygonRotation: polygonRotation
		speculativeDistance: speculativeDistance
		into: points.
	^ self manifoldWithNormal: referenceNormal negated points: points
]

{ #category : 'private - manifold' }
CFPhysicsChainPolygonManifoldBuilder class >> polygonReferenceNormal: referenceNormal referencePoint: referencePoint point1: point1 point2: point2 normal0: normal0 normal1: normal1 normal2: normal2 [
	| dot1 dot2 |
	dot1 := self dot: referenceNormal with: point1 - referencePoint.
	dot2 := self dot: referenceNormal with: point2 - referencePoint.
	dot1 < dot2 ifTrue: [
		^ (self dot: normal0 with: referenceNormal)
			>= (self dot: normal1 with: referenceNormal) ].
	^ (self dot: normal2 with: referenceNormal)
		>= (self dot: normal1 with: referenceNormal)
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
		point
			localAnchorA: point localAnchorB;
			localAnchorB: anchor.
		feature := point featureId.
		point featureId: (CFPhysicsContactFeatureId
			featureA: feature featureB index: feature indexB
			featureB: feature featureA index: feature indexA) ]
]

{ #category : 'private - geometry' }
CFPhysicsChainPolygonManifoldBuilder class >> normalized: vector [
	| length |
	length := vector r.
	length <= Float epsilon ifTrue: [ ^ nil ].
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
