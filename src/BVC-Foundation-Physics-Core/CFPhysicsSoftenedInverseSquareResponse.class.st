Class {
	#name : 'CFPhysicsSoftenedInverseSquareResponse',
	#superclass : 'CFPhysicsDistanceResponse',
	#instVars : [ 'force', 'softeningDistance', 'maximumDistance' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
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
CFPhysicsSoftenedInverseSquareResponse >> force: aValue [
	aValue isNumber
		ifTrue: [ force := aValue asFloat max: 0.0 ]
		ifFalse: [
			aValue value asFloat.
			force := aValue ]
]

{ #category : 'accessing' }
CFPhysicsSoftenedInverseSquareResponse >> maximumDistance [
	^ maximumDistance
]

{ #category : 'accessing' }
CFPhysicsSoftenedInverseSquareResponse >> maximumDistance: aValue [
	aValue ifNil: [
		maximumDistance := nil.
		^ self ].
	aValue isNumber
		ifTrue: [ maximumDistance := aValue asFloat max: 0.0 ]
		ifFalse: [
			aValue value asFloat.
			maximumDistance := aValue ]
]

{ #category : 'accessing' }
CFPhysicsSoftenedInverseSquareResponse >> softeningDistance [
	^ softeningDistance
]

{ #category : 'accessing' }
CFPhysicsSoftenedInverseSquareResponse >> softeningDistance: aValue [
	aValue isNumber
		ifTrue: [ softeningDistance := aValue asFloat max: 0.0 ]
		ifFalse: [
			aValue value asFloat.
			softeningDistance := aValue ]
]

{ #category : 'evaluating' }
CFPhysicsSoftenedInverseSquareResponse >> forceMagnitudeAtDistance: aNumber [
	| distanceSquared resolvedForce resolvedMaximumDistance resolvedSofteningDistance softeningSquared |
	resolvedMaximumDistance := maximumDistance ifNil: [ nil ] ifNotNil: [ maximumDistance value ].
	(maximumDistance notNil and: [ aNumber > resolvedMaximumDistance ])
		ifTrue: [ ^ 0.0 ].
	resolvedSofteningDistance := softeningDistance value.
	resolvedSofteningDistance = 0.0 ifTrue: [ ^ 0.0 ].
	distanceSquared := aNumber asFloat squared.
	softeningSquared := resolvedSofteningDistance squared.
	resolvedForce := force value.
	^ resolvedForce * softeningSquared / (distanceSquared + softeningSquared)
]
