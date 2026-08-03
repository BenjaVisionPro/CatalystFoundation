"
I build clipped contact manifolds between convex polygons from explicit geometry and transforms.

My responsibility is to select reference and incident faces, clip their overlap and assign stable contact features.
"
Class {
	#name : 'CFPhysicsPolygonManifoldBuilder',
	#superclass : 'Object',
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'collision' }
CFPhysicsPolygonManifoldBuilder class >> manifoldBetweenShape: shapeA bodyOrigin: bodyOriginA rotation: rotationA andShape: shapeB bodyOrigin: bodyOriginB rotation: rotationB [
	^ self
		manifoldBetweenShape: shapeA
		bodyOrigin: bodyOriginA
		rotation: rotationA
		andShape: shapeB
		bodyOrigin: bodyOriginB
		rotation: rotationB
		speculativeDistance: 0.0
]

{ #category : 'collision' }
CFPhysicsPolygonManifoldBuilder class >> manifoldBetweenShape: shapeA bodyOrigin: bodyOriginA rotation: rotationA andShape: shapeB bodyOrigin: bodyOriginB rotation: rotationB speculativeDistance: speculativeDistance [
	| verticesA normalsA verticesB normalsB separationA separationB referenceIsA referenceShape referenceRotation referenceVertices referenceNormals incidentShape incidentRotation incidentVertices incidentNormals referenceIndex referenceNormal referenceVertex1 referenceVertex2 tangent incidentEdge clipped totalRadius points manifoldNormal penetration maximumSeparation |
	verticesA := shapeA worldVerticesAtBodyOrigin: bodyOriginA rotation: rotationA.
	normalsA := shapeA worldNormalsAtRotation: rotationA.
	verticesB := shapeB worldVerticesAtBodyOrigin: bodyOriginB rotation: rotationB.
	normalsB := shapeB worldNormalsAtRotation: rotationB.
	totalRadius := shapeA radius + shapeB radius.
	maximumSeparation := totalRadius + speculativeDistance.

	separationA := self maximumSeparationOf: verticesA normals: normalsA from: verticesB.
	separationA second > maximumSeparation ifTrue: [ ^ nil ].
	separationB := self maximumSeparationOf: verticesB normals: normalsB from: verticesA.
	separationB second > maximumSeparation ifTrue: [ ^ nil ].

	referenceIsA := separationB second <= separationA second.
	referenceIsA
		ifTrue: [
			referenceShape := shapeA.
			referenceRotation := rotationA.
			referenceVertices := verticesA.
			referenceNormals := normalsA.
			incidentShape := shapeB.
			incidentRotation := rotationB.
			incidentVertices := verticesB.
			incidentNormals := normalsB.
			referenceIndex := separationA first ]
		ifFalse: [
			referenceShape := shapeB.
			referenceRotation := rotationB.
			referenceVertices := verticesB.
			referenceNormals := normalsB.
			incidentShape := shapeA.
			incidentRotation := rotationA.
			incidentVertices := verticesA.
			incidentNormals := normalsA.
			referenceIndex := separationB first ].

	referenceNormal := referenceNormals at: referenceIndex.
	referenceVertex1 := referenceVertices at: referenceIndex.
	referenceVertex2 := referenceVertices at: (referenceIndex = referenceVertices size ifTrue: [ 1 ] ifFalse: [ referenceIndex + 1 ]).
	tangent := referenceVertex2 - referenceVertex1.
	tangent := tangent / tangent r.
	incidentEdge := self incidentEdgeFrom: incidentVertices normals: incidentNormals referenceNormal: referenceNormal.
	clipped := self clip: incidentEdge toNormal: tangent negated offset: (self dot: tangent negated with: referenceVertex1).
	clipped size < 2 ifTrue: [ ^ nil ].
	clipped := self clip: clipped toNormal: tangent offset: (self dot: tangent with: referenceVertex2).
	clipped isEmpty ifTrue: [ ^ nil ].

	points := OrderedCollection new: 2.
	clipped do: [ :clipVertex |
		| coreSeparation separation worldPoint point featureId |
		coreSeparation := self dot: clipVertex position - referenceVertex1 with: referenceNormal.
		separation := coreSeparation - totalRadius.
		separation <= speculativeDistance ifTrue: [
			worldPoint := clipVertex position
				- (referenceNormal * ((coreSeparation + incidentShape radius - referenceShape radius) / 2.0)).
			featureId := referenceIsA
				ifTrue: [ CFPhysicsContactFeatureId
					featureA: #face index: referenceIndex
					featureB: #vertex index: clipVertex incidentVertexIndex ]
				ifFalse: [ CFPhysicsContactFeatureId
					featureA: #vertex index: clipVertex incidentVertexIndex
					featureB: #face index: referenceIndex ].
			point := CFPhysicsManifoldPoint at: worldPoint.
			point
				separation: separation;
				featureId: featureId;
				localAnchorA: (shapeA localPointForWorldPoint: worldPoint bodyOrigin: bodyOriginA rotation: rotationA);
				localAnchorB: (shapeB localPointForWorldPoint: worldPoint bodyOrigin: bodyOriginB rotation: rotationB).
			points add: point ] ].
	points isEmpty ifTrue: [ ^ nil ].
	manifoldNormal := referenceIsA ifTrue: [ referenceNormal ] ifFalse: [ referenceNormal negated ].
	penetration := (points collect: [ :each | each separation negated ]) max.
	^ (CFPhysicsManifold normal: manifoldNormal penetration: penetration)
		contactPoints: points;
		yourself
]
{ #category : 'private' }
CFPhysicsPolygonManifoldBuilder class >> maximumSeparationOf: referenceVertices normals: referenceNormals from: incidentVertices [
	| bestIndex bestSeparation |
	bestIndex := 1.
	bestSeparation := Float negativeInfinity.
	1 to: referenceVertices size do: [ :index |
		| vertex normal minimumSeparation |
		vertex := referenceVertices at: index.
		normal := referenceNormals at: index.
		minimumSeparation := Float infinity.
		incidentVertices do: [ :incidentVertex |
			minimumSeparation := minimumSeparation min:
				(self dot: incidentVertex - vertex with: normal) ].
		minimumSeparation > bestSeparation ifTrue: [
			bestSeparation := minimumSeparation.
			bestIndex := index ] ].
	^ { bestIndex. bestSeparation }
]

{ #category : 'private' }
CFPhysicsPolygonManifoldBuilder class >> incidentEdgeFrom: vertices normals: normals referenceNormal: referenceNormal [
	| incidentIndex minimumDot secondIndex |
	incidentIndex := 1.
	minimumDot := self dot: referenceNormal with: normals first.
	2 to: normals size do: [ :index |
		| value |
		value := self dot: referenceNormal with: (normals at: index).
		value < minimumDot ifTrue: [
			minimumDot := value.
			incidentIndex := index ] ].
	secondIndex := incidentIndex = vertices size ifTrue: [ 1 ] ifFalse: [ incidentIndex + 1 ].
	^ {
		CFPhysicsClipVertex position: (vertices at: incidentIndex) incidentVertexIndex: incidentIndex.
		CFPhysicsClipVertex position: (vertices at: secondIndex) incidentVertexIndex: secondIndex }
]

{ #category : 'private' }
CFPhysicsPolygonManifoldBuilder class >> clip: clipVertices toNormal: normal offset: offset [
	| output first second distanceFirst distanceSecond interpolation intersection sourceIndex |
	clipVertices isEmpty ifTrue: [ ^ #() ].
	clipVertices size = 1 ifTrue: [
		^ ((self dot: normal with: clipVertices first position) - offset) <= 0
			ifTrue: [ clipVertices ]
			ifFalse: [ #() ] ].
	first := clipVertices first.
	second := clipVertices second.
	distanceFirst := (self dot: normal with: first position) - offset.
	distanceSecond := (self dot: normal with: second position) - offset.
	output := OrderedCollection new: 2.
	distanceFirst <= 0 ifTrue: [ output add: first ].
	distanceSecond <= 0 ifTrue: [ output add: second ].
	(distanceFirst * distanceSecond < 0) ifTrue: [
		interpolation := distanceFirst / (distanceFirst - distanceSecond).
		intersection := first position + ((second position - first position) * interpolation).
		sourceIndex := distanceFirst > 0
			ifTrue: [ first incidentVertexIndex ]
			ifFalse: [ second incidentVertexIndex ].
		output add: (CFPhysicsClipVertex position: intersection incidentVertexIndex: sourceIndex) ].
	^ output asArray
]

{ #category : 'private' }
CFPhysicsPolygonManifoldBuilder class >> dot: firstPoint with: secondPoint [
	^ (firstPoint x * secondPoint x) + (firstPoint y * secondPoint y)
]
