Class {
	#name : 'CFPhysicsLinearFalloffResponse',
	#superclass : 'CFPhysicsDistanceResponse',
	#instVars : [ 'force', 'maximumDistance' ],
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
}

{ #category : 'instance creation' }
CFPhysicsLinearFalloffResponse class >> force: aForce maximumDistance: aDistance [
	^ self new
		force: aForce;
		maximumDistance: aDistance;
		yourself
]

{ #category : 'initialization' }
CFPhysicsLinearFalloffResponse >> initialize [
	super initialize.
	force := 1000.0.
	maximumDistance := 100.0
]

{ #category : 'accessing' }
CFPhysicsLinearFalloffResponse >> force [
	^ force
]

{ #category : 'accessing' }
CFPhysicsLinearFalloffResponse >> force: aNumber [
	force := aNumber asFloat max: 0.0
]

{ #category : 'accessing' }
CFPhysicsLinearFalloffResponse >> maximumDistance [
	^ maximumDistance
]

{ #category : 'accessing' }
CFPhysicsLinearFalloffResponse >> maximumDistance: aNumber [
	maximumDistance := aNumber asFloat max: 0.0
]

{ #category : 'evaluating' }
CFPhysicsLinearFalloffResponse >> forceMagnitudeAtDistance: aNumber [
	maximumDistance = 0.0 ifTrue: [ ^ 0.0 ].
	^ force * (1.0 - (aNumber asFloat / maximumDistance)) max: 0.0
]
