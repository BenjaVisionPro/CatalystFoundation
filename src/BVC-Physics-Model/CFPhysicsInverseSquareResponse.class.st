"
I represent an inverse-square force response expressed in physical units.

force is the force magnitude in newtons at one metre.
maximumDistance, when present, is expressed in metres.
"
Class {
	#name : 'CFPhysicsInverseSquareResponse',
	#superclass : 'CFPhysicsDistanceResponse',
	#instVars : [ 'force', 'maximumDistance' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsInverseSquareResponse class >> force: aForce [
	^ self new
		force: aForce;
		yourself
]

{ #category : 'initialization' }
CFPhysicsInverseSquareResponse >> initialize [
	super initialize.
	force := 1.0.
	maximumDistance := nil
]

{ #category : 'accessing' }
CFPhysicsInverseSquareResponse >> force [
	^ force
]

{ #category : 'accessing' }
CFPhysicsInverseSquareResponse >> force: aValue [
	aValue isNumber
		ifTrue: [ force := aValue asFloat max: 0.0 ]
		ifFalse: [
			aValue value asFloat.
			force := aValue ]
]

{ #category : 'accessing' }
CFPhysicsInverseSquareResponse >> maximumDistance [
	^ maximumDistance
]

{ #category : 'accessing' }
CFPhysicsInverseSquareResponse >> maximumDistance: aValue [
	aValue ifNil: [
		maximumDistance := nil.
		^ self ].
	aValue isNumber
		ifTrue: [ maximumDistance := aValue asFloat max: 0.0 ]
		ifFalse: [
			aValue value asFloat.
			maximumDistance := aValue ]
]

{ #category : 'evaluating' }
CFPhysicsInverseSquareResponse >> forceMagnitudeAtDistance: metres [
	| resolvedMaximumDistance resolvedForce distance |
	distance := metres asFloat.
	distance <= 0.0 ifTrue: [ ^ 0.0 ].
	resolvedMaximumDistance := maximumDistance ifNil: [ nil ] ifNotNil: [ maximumDistance value ].
	(resolvedMaximumDistance notNil and: [ distance > resolvedMaximumDistance ])
		ifTrue: [ ^ 0.0 ].
	resolvedForce := force value asFloat max: 0.0.
	^ resolvedForce / distance squared
]
