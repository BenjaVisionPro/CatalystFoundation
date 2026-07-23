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
CFPhysicsConstantForceResponse >> force: aValue [
	aValue isNumber
		ifTrue: [ force := aValue asFloat max: 0.0 ]
		ifFalse: [
			aValue physicsValue asFloat.
			force := aValue ]
]

{ #category : 'accessing' }
CFPhysicsConstantForceResponse >> maximumDistance [
	^ maximumDistance
]

{ #category : 'accessing' }
CFPhysicsConstantForceResponse >> maximumDistance: aValue [
	aValue ifNil: [
		maximumDistance := nil.
		^ self ].
	aValue isNumber
		ifTrue: [ maximumDistance := aValue asFloat max: 0.0 ]
		ifFalse: [
			aValue physicsValue asFloat.
			maximumDistance := aValue ]
]

{ #category : 'evaluating' }
CFPhysicsConstantForceResponse >> forceMagnitudeAtDistance: aNumber [
	| resolvedMaximumDistance |
	resolvedMaximumDistance := maximumDistance physicsValue.
	(resolvedMaximumDistance notNil and: [
		aNumber > (resolvedMaximumDistance asFloat max: 0.0) ])
		ifTrue: [ ^ 0.0 ].
	^ force physicsValue asFloat max: 0.0
]
