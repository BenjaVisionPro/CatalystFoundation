
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
