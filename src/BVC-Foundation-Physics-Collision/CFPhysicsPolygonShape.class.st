Class {
	#name : 'CFPhysicsPolygonShape',
	#superclass : 'Object',
	#instVars : [ 'vertices', 'normals', 'radius', 'rotationCentre' ],
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsPolygonShape class >> vertices: aCollection radius: aNumber [
	| shape |
	shape := self new
		vertices: aCollection;
		radius: aNumber;
		yourself.
	shape
		rotationCentre: shape inferredRotationCentre;
		computeNormals.
	^ shape
]

{ #category : 'instance creation' }
CFPhysicsPolygonShape class >> vertices: aCollection radius: aNumber rotationCentre: aPoint [
	^ self new
		vertices: aCollection;
		radius: aNumber;
		rotationCentre: aPoint;
		computeNormals;
		yourself
]

{ #category : 'instance creation' }
CFPhysicsPolygonShape class >> rectangleExtent: anExtent [
	^ self rectangleExtent: anExtent radius: 0.0
]

{ #category : 'instance creation' }
CFPhysicsPolygonShape class >> rectangleExtent: anExtent radius: aRadius [
	| radiusValue |
	radiusValue := aRadius asFloat.
	^ self
		vertices: {
			radiusValue @ radiusValue.
			(anExtent x - radiusValue) @ radiusValue.
			(anExtent x - radiusValue) @ (anExtent y - radiusValue).
			radiusValue @ (anExtent y - radiusValue) }
		radius: radiusValue
		rotationCentre: anExtent / 2.0
]

{ #category : 'initialization' }
CFPhysicsPolygonShape >> initialize [
	super initialize.
	vertices := #().
	normals := #().
	radius := 0.0.
	rotationCentre := 0.0 @ 0.0
]

{ #category : 'initialization' }
CFPhysicsPolygonShape >> computeNormals [
	| computed count |
	vertices size < 3 ifTrue: [ self error: 'A polygon requires at least three vertices' ].
	computed := OrderedCollection new: vertices size.
	count := vertices size.
	1 to: count do: [ :index |
		| first second edge normal |
		first := vertices at: index.
		second := vertices at: (index = count ifTrue: [ 1 ] ifFalse: [ index + 1 ]).
		edge := second - first.
		edge r = 0 ifTrue: [ self error: 'A polygon edge may not have zero length' ].
		normal := edge y @ edge x negated.
		computed add: normal / normal r ].
	normals := computed asArray
]

{ #category : 'accessing' }
CFPhysicsPolygonShape >> vertices [ ^ vertices ]

{ #category : 'accessing' }
CFPhysicsPolygonShape >> vertices: aCollection [
	vertices := aCollection asArray
]

{ #category : 'accessing' }
CFPhysicsPolygonShape >> normals [ ^ normals ]

{ #category : 'accessing' }
CFPhysicsPolygonShape >> radius [ ^ radius ]

{ #category : 'accessing' }
CFPhysicsPolygonShape >> radius: aNumber [
	radius := aNumber asFloat
]

{ #category : 'accessing' }
CFPhysicsPolygonShape >> rotationCentre [
	^ rotationCentre
]

{ #category : 'accessing' }
CFPhysicsPolygonShape >> rotationCentre: aPoint [
	rotationCentre := aPoint
]

{ #category : 'geometry' }
CFPhysicsPolygonShape >> inferredRotationCentre [
	| minimumX minimumY maximumX maximumY |
	vertices ifEmpty: [ ^ 0.0 @ 0.0 ].
	minimumX := maximumX := vertices first x.
	minimumY := maximumY := vertices first y.
	vertices allButFirst do: [ :vertex |
		minimumX := minimumX min: vertex x.
		minimumY := minimumY min: vertex y.
		maximumX := maximumX max: vertex x.
		maximumY := maximumY max: vertex y ].
	^ ((minimumX + maximumX) / 2.0) @ ((minimumY + maximumY) / 2.0)
]

{ #category : 'geometry' }
CFPhysicsPolygonShape >> worldVerticesAt: aPosition rotation: anAngle [
	^ vertices collect: [ :vertex |
		aPosition + (self rotate: vertex around: rotationCentre by: anAngle) ]
]

{ #category : 'geometry' }
CFPhysicsPolygonShape >> worldNormalsAtRotation: anAngle [
	^ normals collect: [ :normal | self rotate: normal by: anAngle ]
]

{ #category : 'geometry' }
CFPhysicsPolygonShape >> localPointForWorldPoint: aPoint position: aPosition rotation: anAngle [
	^ self
		rotate: aPoint - aPosition
		around: rotationCentre
		by: anAngle negated
]

{ #category : 'geometry' }
CFPhysicsPolygonShape >> rotate: aPoint by: anAngle [
	| cosine sine |
	anAngle = 0 ifTrue: [ ^ aPoint ].
	cosine := anAngle cos.
	sine := anAngle sin.
	^ ((aPoint x * cosine) - (aPoint y * sine))
		@ ((aPoint x * sine) + (aPoint y * cosine))
]


{ #category : 'geometry' }
CFPhysicsPolygonShape >> rotate: aPoint around: aCentre by: anAngle [
	^ aCentre + (self rotate: aPoint - aCentre by: anAngle)
]
