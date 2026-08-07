"
I represent a force response that decreases linearly with distance.

My responsibility is to interpolate from full force in newtons to zero across a configured range in metres.
"
Class {
	#name : 'CFPhysicsLinearFalloffResponse',
	#superclass : 'CFPhysicsDistanceResponse',
	#instVars : [ 'force', 'maximumDistance' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
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
	force := 1.0.
	maximumDistance := 1.0
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
