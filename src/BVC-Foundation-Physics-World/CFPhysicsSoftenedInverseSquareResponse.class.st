Class {
	#name : 'CFPhysicsSoftenedInverseSquareResponse',
	#superclass : 'CFPhysicsDistanceResponse',
	#instVars : [ 'force', 'softeningDistance', 'maximumDistance' ],
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
}

{ #category : 'instance creation' }
CFPhysicsSoftenedInverseSquareResponse class >> force: aForce softeningDistance: aDistance [
	^ self new
		force: aForce;
		softeningDistance: aDistance;
		yourself
]

{ #category : 'initialization' }
CFPhysicsSoftenedInverseSquareResponse >> initialize [
	super initialize.
	force := 1000.0.
	softeningDistance := 10.0.
	maximumDistance := nil
]

{ #category : 'accessing' }
CFPhysicsSoftenedInverseSquareResponse >> force [
	^ force
]

{ #category : 'accessing' }
CFPhysicsSoftenedInverseSquareResponse >> force: aNumber [
	force := aNumber asFloat max: 0.0
]

{ #category : 'accessing' }
CFPhysicsSoftenedInverseSquareResponse >> maximumDistance [
	^ maximumDistance
]

{ #category : 'accessing' }
CFPhysicsSoftenedInverseSquareResponse >> maximumDistance: aNumber [
	aNumber ifNil: [
		maximumDistance := nil.
		^ self ].
	maximumDistance := aNumber asFloat max: 0.0
]

{ #category : 'accessing' }
CFPhysicsSoftenedInverseSquareResponse >> softeningDistance [
	^ softeningDistance
]

{ #category : 'accessing' }
CFPhysicsSoftenedInverseSquareResponse >> softeningDistance: aNumber [
	softeningDistance := aNumber asFloat max: 0.0
]

{ #category : 'evaluating' }
CFPhysicsSoftenedInverseSquareResponse >> forceMagnitudeAtDistance: aNumber [
	| distanceSquared softeningSquared |
	(maximumDistance notNil and: [ aNumber > maximumDistance ])
		ifTrue: [ ^ 0.0 ].
	softeningDistance = 0.0 ifTrue: [ ^ 0.0 ].
	distanceSquared := aNumber asFloat squared.
	softeningSquared := softeningDistance squared.
	^ force * softeningSquared / (distanceSquared + softeningSquared)
]
