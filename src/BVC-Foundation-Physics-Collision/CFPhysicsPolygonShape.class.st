Class {
	#name : 'CFPhysicsPolygonShape',
	#superclass : 'Object',
	#instVars : [ 'vertices', 'normals', 'radius' ],
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsPolygonShape class >> vertices: aCollection radius: aNumber [
	^ self new
		vertices: aCollection;
		radius: aNumber;
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
]

{ #category : 'initialization' }
CFPhysicsPolygonShape >> initialize [
	super initialize.
	vertices := #().
	normals := #().
	radius := 0.0
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

{ #category : 'geometry' }
CFPhysicsPolygonShape >> worldVerticesAt: aPosition rotation: anAngle [
	^ vertices collect: [ :vertex |
		aPosition + (self rotate: vertex by: anAngle) ]
]

{ #category : 'geometry' }
CFPhysicsPolygonShape >> worldNormalsAtRotation: anAngle [
	^ normals collect: [ :normal | self rotate: normal by: anAngle ]
]

{ #category : 'geometry' }
CFPhysicsPolygonShape >> localPointForWorldPoint: aPoint position: aPosition rotation: anAngle [
	^ self rotate: aPoint - aPosition by: anAngle negated
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
