
"
I build immutable Physics geometry from resolved Bloc element geometry.

Known Bloc geometries retain their semantics. Unsupported geometries are rejected rather than silently colliding as their bounds.
"
Class {
	#name : 'CFPhysicsBlocGeometryBuilder',
	#superclass : 'Object',
	#category : 'BVC-Physics-Bloc',
	#package : 'BVC-Physics-Bloc'
}

{ #category : 'converting' }
CFPhysicsBlocGeometryBuilder class >> collisionGeometryFor: aGeometry extent: anExtent [
	| radii radius |
	(aGeometry isKindOf: BlCircleGeometry) ifTrue: [
		^ CFPhysicsCapturedCircleGeometry radius: anExtent min / 2.0 ].
	(aGeometry isKindOf: BlEllipseGeometry) ifTrue: [
		^ self ellipseGeometryForExtent: anExtent ].
	(aGeometry isKindOf: BlRectangleGeometry) ifTrue: [
		^ CFPhysicsCapturedPolygonGeometry
			vertices: { 0 @ 0. anExtent x @ 0. anExtent. 0 @ anExtent y }
			radius: 0.0
			rotationCentre: anExtent / 2.0 ].
	(aGeometry isKindOf: BlPolygonGeometry) ifTrue: [
		^ CFPhysicsCapturedPolygonGeometry
			vertices: aGeometry vertices
			radius: 0.0
			rotationCentre: anExtent / 2.0 ].
	(aGeometry isKindOf: BlNormalizedPolygonGeometry) ifTrue: [
		^ CFPhysicsCapturedPolygonGeometry
			vertices: (aGeometry vertices collect: [ :each |
				(each x * anExtent x) @ (each y * anExtent y) ])
			radius: 0.0
			rotationCentre: anExtent / 2.0 ].
	(aGeometry isKindOf: BlRoundedRectangleGeometry) ifTrue: [
		radii := aGeometry cornerRadii.
		radius := radii topLeft.
		((radii topRight = radius)
			and: [ radii bottomRight = radius
				and: [ radii bottomLeft = radius ] ])
			ifFalse: [ self error: 'Physics currently requires equal rounded-rectangle corner radii' ].
		radius := radius min: anExtent min / 2.0.
		^ CFPhysicsCapturedPolygonGeometry
			vertices: {
				radius @ radius.
				(anExtent x - radius) @ radius.
				(anExtent x - radius) @ (anExtent y - radius).
				radius @ (anExtent y - radius) }
			radius: radius
			rotationCentre: anExtent / 2.0 ].
	self error: 'Unsupported Bloc geometry for Physics: ', aGeometry class name
]

{ #category : 'converting' }
CFPhysicsBlocGeometryBuilder class >> ellipseGeometryForExtent: anExtent [
	| centre xRadius yRadius vertices |
	centre := anExtent / 2.0.
	xRadius := anExtent x / 2.0.
	yRadius := anExtent y / 2.0.
	vertices := (0 to: 7) collect: [ :index |
		| angle |
		angle := Float pi * 2.0 * index / 8.0.
		centre + ((angle cos * xRadius) @ (angle sin * yRadius)) ].
	^ CFPhysicsCapturedPolygonGeometry
		vertices: vertices
		radius: 0.0
		rotationCentre: centre
]


{ #category : 'building - boundaries' }
CFPhysicsBlocGeometryBuilder class >> boundaryVerticesFor: aGeometry extent: anExtent [
	| radii radius |
	(aGeometry isKindOf: BlCircleGeometry) ifTrue: [
		^ self ellipseBoundaryVerticesForExtent: anExtent segmentCount: 32 ].
	(aGeometry isKindOf: BlEllipseGeometry) ifTrue: [
		^ self ellipseBoundaryVerticesForExtent: anExtent segmentCount: 32 ].
	(aGeometry isKindOf: BlRectangleGeometry) ifTrue: [
		^ { 0 @ 0. anExtent x @ 0. anExtent. 0 @ anExtent y } ].
	(aGeometry isKindOf: BlPolygonGeometry) ifTrue: [
		^ aGeometry vertices asArray copy ].
	(aGeometry isKindOf: BlNormalizedPolygonGeometry) ifTrue: [
		^ (aGeometry vertices collect: [ :each |
			(each x * anExtent x) @ (each y * anExtent y) ]) asArray ].
	(aGeometry isKindOf: BlRoundedRectangleGeometry) ifTrue: [
		radii := aGeometry cornerRadii.
		radius := radii topLeft.
		((radii topRight = radius)
			and: [ radii bottomRight = radius
				and: [ radii bottomLeft = radius ] ])
			ifFalse: [ self error: 'Physics currently requires equal rounded-rectangle corner radii' ].
		^ self roundedRectangleBoundaryVerticesForExtent: anExtent radius: (radius min: anExtent min / 2.0) ].
	self error: 'Unsupported Bloc geometry for Physics boundary: ', aGeometry class name
]

{ #category : 'building - boundaries' }
CFPhysicsBlocGeometryBuilder class >> ellipseBoundaryVerticesForExtent: anExtent segmentCount: segmentCount [
	| centre xRadius yRadius |
	centre := anExtent / 2.0.
	xRadius := anExtent x / 2.0.
	yRadius := anExtent y / 2.0.
	^ (0 to: segmentCount - 1) collect: [ :index |
		| angle |
		angle := Float pi * 2.0 * index / segmentCount.
		centre + ((angle cos * xRadius) @ (angle sin * yRadius)) ]
]

{ #category : 'building - boundaries' }
CFPhysicsBlocGeometryBuilder class >> roundedRectangleBoundaryVerticesForExtent: anExtent radius: radius [
	| corners vertices |
	radius <= 0.0 ifTrue: [ ^ { 0 @ 0. anExtent x @ 0. anExtent. 0 @ anExtent y } ].
	corners := {
		{ (anExtent x - radius) @ radius. Float pi * 1.5 }.
		{ (anExtent x - radius) @ (anExtent y - radius). 0.0 }.
		{ radius @ (anExtent y - radius). Float pi * 0.5 }.
		{ radius @ radius. Float pi } }.
	vertices := OrderedCollection new: 32.
	corners do: [ :corner |
		0 to: 7 do: [ :index |
			| angle |
			angle := corner second + (Float pi * 0.5 * index / 8.0).
			vertices add: corner first + ((angle cos * radius) @ (angle sin * radius)) ] ].
	^ vertices asArray
]
