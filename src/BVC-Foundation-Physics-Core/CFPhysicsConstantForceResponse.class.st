Class {
	#name : 'CFPhysicsConstantForceResponse',
	#superclass : 'CFPhysicsDistanceResponse',
	#instVars : [ 'force', 'maximumDistance' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsConstantForceResponse class >> force: aNumber [
	^ self new
		force: aNumber;
		yourself
]

{ #category : 'initialization' }
CFPhysicsConstantForceResponse >> initialize [
	super initialize.
	force := 1000.0.
	maximumDistance := nil
]

{ #category : 'accessing' }
CFPhysicsConstantForceResponse >> force [
	^ force
]

{ #category : 'accessing' }
CFPhysicsConstantForceResponse >> force: aNumber [
	force := aNumber asFloat max: 0.0
]

{ #category : 'accessing' }
CFPhysicsConstantForceResponse >> maximumDistance [
	^ maximumDistance
]

{ #category : 'accessing' }
CFPhysicsConstantForceResponse >> maximumDistance: aNumber [
	aNumber ifNil: [
		maximumDistance := nil.
		^ self ].
	maximumDistance := aNumber asFloat max: 0.0
]

{ #category : 'evaluating' }
CFPhysicsConstantForceResponse >> forceMagnitudeAtDistance: aNumber [
	(maximumDistance notNil and: [ aNumber > maximumDistance ])
		ifTrue: [ ^ 0.0 ].
	^ force
]
