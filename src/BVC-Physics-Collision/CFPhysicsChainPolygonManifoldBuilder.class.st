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
	^ self
		manifoldBetweenChainSegment: segment
		bodyOrigin: segmentBodyOrigin
		rotation: segmentRotation
		andPolygonShapeState: polygonState
		bodyOrigin: polygonBodyOrigin
		rotation: polygonRotation
		speculativeDistance: speculativeDistance
		simplexCache: CFPhysicsSimplexCache empty
]

{ #category : 'collision' }
CFPhysicsChainPolygonManifoldBuilder class >> manifoldBetweenChainSegment: segment bodyOrigin: segmentBodyOrigin rotation: segmentRotation andPolygonShapeState: polygonState bodyOrigin: polygonBodyOrigin rotation: polygonRotation speculativeDistance: speculativeDistance simplexCache: simplexCache [
	| polygon vertices normals centroid distanceResult separatedManifold chainSeparation polygonSeparation |
	polygon := polygonState polygonShape.
	polygon ifNil: [ ^ nil ].
	vertices := polygon worldVerticesAtBodyOrigin: polygonBodyOrigin rotation: polygonRotation.
	vertices isEmpty ifTrue: [ ^ nil ].
	normals := polygon worldNormalsAtRotation: polygonRotation.
	centroid := polygon worldCentroidAtBodyOrigin: polygonBodyOrigin rotation: polygonRotation.
	(self
		polygonCentroid: centroid
		isBehindChainSegment: segment
		bodyOrigin: segmentBodyOrigin
		rotation: segmentRotation) ifTrue: [ ^ nil ].
	distanceResult := self
		distanceBetweenChainSegment: segment
		bodyOrigin: segmentBodyOrigin
		rotation: segmentRotation
		andPolygon: polygon
		vertices: vertices
		bodyOrigin: polygonBodyOrigin
		rotation: polygonRotation
		using: simplexCache.
	distanceResult distance > (polygon radius + speculativeDistance) ifTrue: [ ^ nil ].
	separatedManifold := self
		separatedManifoldFrom: distanceResult
		cache: simplexCache
		segment: segment
		segmentBodyOrigin: segmentBodyOrigin
		segmentRotation: segmentRotation
		polygon: polygon
		vertices: vertices
		normals: normals
		polygonState: polygonState
		polygonBodyOrigin: polygonBodyOrigin
		polygonRotation: polygonRotation
		speculativeDistance: speculativeDistance.
	separatedManifold == #skip ifTrue: [ ^ nil ].
	separatedManifold ifNotNil: [ ^ separatedManifold ].
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
	^ self
		manifoldBetweenPolygonShapeState: polygonState
		bodyOrigin: polygonBodyOrigin
		rotation: polygonRotation
		andChainSegment: segment
		bodyOrigin: segmentBodyOrigin
		rotation: segmentRotation
		speculativeDistance: speculativeDistance
		simplexCache: CFPhysicsSimplexCache empty
]

{ #category : 'collision' }
CFPhysicsChainPolygonManifoldBuilder class >> manifoldBetweenPolygonShapeState: polygonState bodyOrigin: polygonBodyOrigin rotation: polygonRotation andChainSegment: segment bodyOrigin: segmentBodyOrigin rotation: segmentRotation speculativeDistance: speculativeDistance simplexCache: simplexCache [
	| manifold |
	manifold := self
		manifoldBetweenChainSegment: segment
		bodyOrigin: segmentBodyOrigin
		rotation: segmentRotation
		andPolygonShapeState: polygonState
		bodyOrigin: polygonBodyOrigin
		rotation: polygonRotation
		speculativeDistance: speculativeDistance
		simplexCache: simplexCache.
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
	| point1 point2 edge normal incidentEdge tangent clippedPoints points |
	point1 := segment worldPoint1AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	point2 := segment worldPoint2AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	edge := self unitVectorFrom: point1 to: point2.
	edge ifNil: [ ^ nil ].
	normal := self rightPerpendicular: edge.
	incidentEdge := self incidentEdgeForVertex: incidentIndex normals: normals withSegmentNormal: normal.
	tangent := edge.
	clippedPoints := {
		CFPhysicsClipVertex
			position: (vertices at: incidentEdge first)
			featureId: (CFPhysicsContactFeatureId
				featureA: #face index: segment segmentIndex
				featureB: #vertex index: incidentEdge first)
			incidentEdgeIndex: incidentEdge first.
		CFPhysicsClipVertex
			position: (vertices at: incidentEdge second)
			featureId: (CFPhysicsContactFeatureId
				featureA: #face index: segment segmentIndex
				featureB: #vertex index: incidentEdge second)
			incidentEdgeIndex: incidentEdge first }.
	clippedPoints := CFPhysicsPolygonManifoldBuilder
		clip: clippedPoints
		toNormal: tangent negated
		offset: (self dot: tangent negated with: point1)
		referenceVertexIndex: 1
		referenceIsA: true.
	clippedPoints size < 2 ifTrue: [ ^ nil ].
	clippedPoints := CFPhysicsPolygonManifoldBuilder
		clip: clippedPoints
		toNormal: tangent
		offset: (self dot: tangent with: point2)
		referenceVertexIndex: 2
		referenceIsA: true.
	clippedPoints isEmpty ifTrue: [ ^ nil ].
	points := OrderedCollection new: 2.
	self
		addClippedPoint: clippedPoints first position
		feature: (CFPhysicsContactFeatureId
			featureA: #vertex index: 1
			featureB: #vertex index: incidentEdge second)
		referencePoint: point1 normal: normal
		referenceRadius: 0.0 incidentRadius: polygon radius
		segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation
		polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation
		speculativeDistance: speculativeDistance into: points.
	self
		addClippedPoint: clippedPoints second position
		feature: (CFPhysicsContactFeatureId
			featureA: #vertex index: 2
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
	| point1 point2 referencePoint1 referencePoint2 referenceNormal secondIndex tangent clippedPoints points |
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
	tangent := self unitVectorFrom: referencePoint1 to: referencePoint2.
	tangent ifNil: [ ^ nil ].
	clippedPoints := {
		CFPhysicsClipVertex
			position: point1
			featureId: (CFPhysicsContactFeatureId
				featureA: #vertex index: 1
				featureB: #face index: referenceIndex)
			incidentEdgeIndex: 1.
		CFPhysicsClipVertex
			position: point2
			featureId: (CFPhysicsContactFeatureId
				featureA: #vertex index: 2
				featureB: #face index: referenceIndex)
			incidentEdgeIndex: 1 }.
	clippedPoints := CFPhysicsPolygonManifoldBuilder
		clip: clippedPoints
		toNormal: tangent negated
		offset: (self dot: tangent negated with: referencePoint1)
		referenceVertexIndex: referenceIndex
		referenceIsA: false.
	clippedPoints size < 2 ifTrue: [ ^ nil ].
	clippedPoints := CFPhysicsPolygonManifoldBuilder
		clip: clippedPoints
		toNormal: tangent
		offset: (self dot: tangent with: referencePoint2)
		referenceVertexIndex: secondIndex
		referenceIsA: false.
	clippedPoints isEmpty ifTrue: [ ^ nil ].
	points := OrderedCollection new: 2.
	self
		addClippedPoint: clippedPoints first position
		feature: (CFPhysicsContactFeatureId featureA: #vertex index: 2 featureB: #vertex index: referenceIndex)
		referencePoint: referencePoint1 normal: referenceNormal
		referenceRadius: polygon radius incidentRadius: 0.0
		segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation
		polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation
		speculativeDistance: speculativeDistance into: points.
	self
		addClippedPoint: clippedPoints second position
		feature: (CFPhysicsContactFeatureId featureA: #vertex index: 1 featureB: #vertex index: secondIndex)
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

{ #category : 'private - distance' }
CFPhysicsChainPolygonManifoldBuilder class >> distanceBetweenChainSegment: segment bodyOrigin: segmentBodyOrigin rotation: segmentRotation andPolygon: polygon vertices: vertices bodyOrigin: polygonBodyOrigin rotation: polygonRotation using: simplexCache [
	| point1 point2 firstProxy secondProxy identity |
	point1 := segment worldPoint1AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	point2 := segment worldPoint2AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	firstProxy := CFPhysicsDistanceProxy points: { point1. point2 } radius: 0.0.
	secondProxy := CFPhysicsDistanceProxy points: vertices radius: 0.0.
	identity := CFPhysicsTransform bodyOrigin: 0 @ 0 rotation: 0.0.
	^ CFPhysicsGJK
		distanceBetweenProxy: firstProxy transform: identity
		andProxy: secondProxy transform: identity
		cache: simplexCache
]

{ #category : 'private - manifold' }
CFPhysicsChainPolygonManifoldBuilder class >> separatedManifoldFrom: distanceResult cache: simplexCache segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation polygon: polygon vertices: vertices normals: normals polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation speculativeDistance: speculativeDistance [
	| point1 point2 edge normal classification firstIndexA secondIndexA firstIndexB secondIndexB polygonNormal firstDot secondDot referenceIndex incidentIndex |
	distanceResult distance <= 0.0005 ifTrue: [ ^ nil ].
	point1 := segment worldPoint1AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	point2 := segment worldPoint2AtBodyOrigin: segmentBodyOrigin rotation: segmentRotation.
	edge := self unitVectorFrom: point1 to: point2.
	edge ifNil: [ ^ #skip ].
	normal := (distanceResult secondPoint - distanceResult firstPoint) / distanceResult distance.
	(self dot: (self rightPerpendicular: edge) with: (polygon worldCentroidAtBodyOrigin: polygonBodyOrigin rotation: polygonRotation) - point1) < 0.0
		ifTrue: [ ^ nil ].
	simplexCache count = 1 ifTrue: [
		classification := self
			classifyWorldNormal: normal
			segment: segment
			bodyOrigin: segmentBodyOrigin
			rotation: segmentRotation.
		classification = #skip ifTrue: [ ^ #skip ].
		classification = #admit ifTrue: [
			^ self
				vertexManifoldFrom: distanceResult
				feature: (CFPhysicsContactFeatureId
					featureA: #vertex index: (simplexCache firstIndexAt: 1)
					featureB: #vertex index: (simplexCache secondIndexAt: 1))
				segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation
				polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation
				polygonRadius: polygon radius ].
		incidentIndex := simplexCache secondIndexAt: 1.
		^ self
			chainReferenceManifoldFor: incidentIndex
			polygon: polygon vertices: vertices normals: normals
			segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation
			polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation
			speculativeDistance: speculativeDistance ].
	simplexCache count = 2 ifFalse: [ ^ nil ].
	firstIndexA := simplexCache firstIndexAt: 1.
	secondIndexA := simplexCache firstIndexAt: 2.
	firstIndexB := simplexCache secondIndexAt: 1.
	secondIndexB := simplexCache secondIndexAt: 2.
	firstIndexA = secondIndexA ifTrue: [
		polygonNormal := distanceResult firstPoint - distanceResult secondPoint.
		firstDot := self dot: polygonNormal with: (normals at: firstIndexB).
		secondDot := self dot: polygonNormal with: (normals at: secondIndexB).
		referenceIndex := firstDot > secondDot ifTrue: [ firstIndexB ] ifFalse: [ secondIndexB ].
		classification := self
			classifyWorldNormal: (normals at: referenceIndex) negated
			segment: segment
			bodyOrigin: segmentBodyOrigin
			rotation: segmentRotation.
		classification = #skip ifTrue: [ ^ #skip ].
		classification = #admit ifTrue: [
			^ self
				polygonReferenceManifoldFor: referenceIndex
				polygon: polygon vertices: vertices normals: normals
				segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation
				polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation
				speculativeDistance: speculativeDistance ].
		incidentIndex := referenceIndex.
		^ self
			chainReferenceManifoldFor: incidentIndex
			polygon: polygon vertices: vertices normals: normals
			segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation
			polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation
			speculativeDistance: speculativeDistance ].
	firstDot := self dot: (self rightPerpendicular: edge) with: (vertices at: firstIndexB) - point1.
	secondDot := self dot: (self rightPerpendicular: edge) with: (vertices at: secondIndexB) - point2.
	incidentIndex := firstDot < secondDot ifTrue: [ firstIndexB ] ifFalse: [ secondIndexB ].
	^ self
		chainReferenceManifoldFor: incidentIndex
		polygon: polygon vertices: vertices normals: normals
		segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation
		polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation
		speculativeDistance: speculativeDistance
]

{ #category : 'private - classification' }
CFPhysicsChainPolygonManifoldBuilder class >> classifyWorldNormal: normal segment: segment bodyOrigin: bodyOrigin rotation: rotation [
	| ghost1 point1 point2 ghost2 edge0 edge1 edge2 normal0 normal2 convex1 convex2 |
	ghost1 := segment worldGhost1AtBodyOrigin: bodyOrigin rotation: rotation.
	point1 := segment worldPoint1AtBodyOrigin: bodyOrigin rotation: rotation.
	point2 := segment worldPoint2AtBodyOrigin: bodyOrigin rotation: rotation.
	ghost2 := segment worldGhost2AtBodyOrigin: bodyOrigin rotation: rotation.
	edge0 := self unitVectorFrom: ghost1 to: point1.
	edge1 := self unitVectorFrom: point1 to: point2.
	edge2 := self unitVectorFrom: point2 to: ghost2.
	(edge0 isNil or: [ edge1 isNil or: [ edge2 isNil ] ]) ifTrue: [ ^ #skip ].
	normal0 := self rightPerpendicular: edge0.
	normal2 := self rightPerpendicular: edge2.
	convex1 := (self cross: edge0 with: edge1) >= 0.01.
	convex2 := (self cross: edge1 with: edge2) >= 0.01.
	^ self classifyNormal: normal edge: edge1 normal0: normal0 normal2: normal2 convex1: convex1 convex2: convex2
]

{ #category : 'private - manifold' }
CFPhysicsChainPolygonManifoldBuilder class >> vertexManifoldFrom: distanceResult feature: feature segment: segment segmentBodyOrigin: segmentBodyOrigin segmentRotation: segmentRotation polygonState: polygonState polygonBodyOrigin: polygonBodyOrigin polygonRotation: polygonRotation polygonRadius: polygonRadius [
	| normal worldPoint point separation |
	normal := (distanceResult secondPoint - distanceResult firstPoint) / distanceResult distance.
	separation := distanceResult distance - polygonRadius.
	worldPoint := distanceResult firstPoint + (normal * (0.5 * (0.0 - polygonRadius - distanceResult distance))).
	point := CFPhysicsManifoldPoint at: worldPoint.
	point
		separation: separation;
		featureId: feature;
		localAnchorA: (segment localPointForWorldPoint: worldPoint bodyOrigin: segmentBodyOrigin rotation: segmentRotation);
		localAnchorB: (polygonState localPointForWorldPoint: worldPoint bodyOrigin: polygonBodyOrigin rotation: polygonRotation).
	^ (CFPhysicsManifold normal: normal penetration: separation negated)
		contactPoints: { point };
		yourself
]
