"
I describe the numerical configuration and identity of one simulation step. I derive substep timing and soft-contact coefficients from world settings.
"

Class {
	#name : 'CFPhysicsStep',
	#superclass : 'Object',
	#instVars : [ 'timeStep', 'substepCount', 'substepTime', 'inverseSubstepTime', 'contactHertz', 'contactDampingRatio', 'biasRate', 'massCoefficient', 'impulseCoefficient', 'staticBiasRate', 'staticMassCoefficient', 'staticImpulseCoefficient', 'maximumContactPushSpeed', 'maximumLinearSpeed', 'hitEventThreshold', 'linearSlop', 'speculativeDistance', 'broadphaseAABBMargin', 'warmStartRatio', 'simulationTime', 'stepNumber' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsStep class >> timeStep: seconds substeps: anInteger contactHertz: hertz dampingRatio: dampingRatio [
	^ self new
		timeStep: seconds;
		substepCount: anInteger;
		contactHertz: hertz;
		contactDampingRatio: dampingRatio;
		prepare;
		yourself
]

{ #category : 'preparing' }
CFPhysicsStep >> prepare [
	| effectiveContactHertz coefficients staticCoefficients |
	warmStartRatio ifNil: [ warmStartRatio := 1.0 ].
	maximumContactPushSpeed ifNil: [ maximumContactPushSpeed := 3.0 ].
	maximumLinearSpeed ifNil: [ maximumLinearSpeed := 400.0 ].
	hitEventThreshold ifNil: [ hitEventThreshold := 1.0 ].
	linearSlop ifNil: [ linearSlop := 0.005 ].
	speculativeDistance ifNil: [ speculativeDistance := 0.02 ].
	broadphaseAABBMargin ifNil: [ broadphaseAABBMargin := 0.05 ].
	substepCount := substepCount max: 1.
	substepTime := timeStep / substepCount.
	inverseSubstepTime := substepTime = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / substepTime ].
	effectiveContactHertz := contactHertz min: 0.125 * inverseSubstepTime.
	coefficients := self softnessForHertz: effectiveContactHertz.
	biasRate := coefficients first.
	massCoefficient := coefficients second.
	impulseCoefficient := coefficients third.
	staticCoefficients := self softnessForHertz: 2.0 * effectiveContactHertz.
	staticBiasRate := staticCoefficients first.
	staticMassCoefficient := staticCoefficients second.
	staticImpulseCoefficient := staticCoefficients third
]


{ #category : 'private - preparing' }
CFPhysicsStep >> softnessForHertz: hertz [
	| omega a1 a2 a3 |
	omega := 2.0 * Float pi * hertz.
	a1 := (2.0 * contactDampingRatio) + (omega * substepTime).
	a2 := substepTime * omega * a1.
	a3 := 1.0 / (1.0 + a2).
	^ {
		a1 = 0.0 ifTrue: [ 0.0 ] ifFalse: [ omega / a1 ].
		a2 * a3.
		a3 }
]

{ #category : 'accessing' }
CFPhysicsStep >> staticBiasRate [ ^ staticBiasRate ]

{ #category : 'accessing' }
CFPhysicsStep >> staticMassCoefficient [ ^ staticMassCoefficient ]

{ #category : 'accessing' }
CFPhysicsStep >> staticImpulseCoefficient [ ^ staticImpulseCoefficient ]

{ #category : 'accessing' }
CFPhysicsStep >> timeStep [ ^ timeStep ]
{ #category : 'accessing' }
CFPhysicsStep >> timeStep: aNumber [ timeStep := aNumber asFloat ]
{ #category : 'accessing' }
CFPhysicsStep >> substepCount [ ^ substepCount ]
{ #category : 'accessing' }
CFPhysicsStep >> substepCount: anInteger [ substepCount := anInteger ]
{ #category : 'accessing' }
CFPhysicsStep >> substepTime [ ^ substepTime ]
{ #category : 'accessing' }
CFPhysicsStep >> inverseSubstepTime [ ^ inverseSubstepTime ]
{ #category : 'accessing' }
CFPhysicsStep >> contactHertz [ ^ contactHertz ]
{ #category : 'accessing' }
CFPhysicsStep >> contactHertz: aNumber [ contactHertz := aNumber asFloat ]
{ #category : 'accessing' }
CFPhysicsStep >> contactDampingRatio [ ^ contactDampingRatio ]
{ #category : 'accessing' }
CFPhysicsStep >> contactDampingRatio: aNumber [ contactDampingRatio := aNumber asFloat ]
{ #category : 'accessing' }
CFPhysicsStep >> biasRate [ ^ biasRate ]
{ #category : 'accessing' }
CFPhysicsStep >> massCoefficient [ ^ massCoefficient ]
{ #category : 'accessing' }
CFPhysicsStep >> impulseCoefficient [ ^ impulseCoefficient ]

{ #category : 'accessing' }
CFPhysicsStep >> maximumContactPushSpeed [
	"Maximum penetration recovery speed in physics length units per second."
	^ maximumContactPushSpeed
]

{ #category : 'accessing' }
CFPhysicsStep >> maximumContactPushSpeed: aNumber [ maximumContactPushSpeed := aNumber asFloat max: 0.0 ]

{ #category : 'accessing' }
CFPhysicsStep >> maximumLinearSpeed [
	"Maximum body speed in physics length units per second."
	maximumLinearSpeed ifNil: [ maximumLinearSpeed := 400.0 ].
	^ maximumLinearSpeed
]

{ #category : 'accessing' }
CFPhysicsStep >> maximumLinearSpeed: aNumber [ maximumLinearSpeed := aNumber asFloat max: 0.0 ]

{ #category : 'accessing' }
CFPhysicsStep >> hitEventThreshold [
	"Minimum collision approach speed for hit events in physics length units per second."
	^ hitEventThreshold
]

{ #category : 'accessing' }
CFPhysicsStep >> hitEventThreshold: aNumber [ hitEventThreshold := aNumber asFloat max: 0.0 ]

{ #category : 'continuous collision' }
CFPhysicsStep >> linearSlop [
	"Box2D's core distance tolerance in physics length units. Capture it on the step so asynchronous solves never read a live world."
	^ linearSlop
]

{ #category : 'continuous collision' }
CFPhysicsStep >> linearSlop: aNumber [
	linearSlop := aNumber asFloat max: 0.0
]

{ #category : 'warm starting' }
CFPhysicsStep >> warmStartRatio [ ^ warmStartRatio ]

{ #category : 'warm starting' }
CFPhysicsStep >> warmStartRatio: aNumber [ warmStartRatio := aNumber asFloat max: 0.0 ]

{ #category : 'simulation identity' }
CFPhysicsStep >> simulationTime [
	^ simulationTime
]

{ #category : 'simulation identity' }
CFPhysicsStep >> simulationTime: aNumber [
	simulationTime := aNumber asFloat
]

{ #category : 'simulation identity' }
CFPhysicsStep >> stepNumber [
	^ stepNumber
]

{ #category : 'simulation identity' }
CFPhysicsStep >> stepNumber: anInteger [
	stepNumber := anInteger
]



{ #category : 'broadphase' }
CFPhysicsStep >> speculativeDistance [
	"Distance in physics length units added around shape bounds so contacts can be prepared before shapes overlap."
	^ speculativeDistance
]

{ #category : 'broadphase' }
CFPhysicsStep >> speculativeDistance: aNumber [
	speculativeDistance := aNumber asFloat max: 0.0
]

{ #category : 'broadphase' }
CFPhysicsStep >> broadphaseAABBMargin [
	"Additional distance in physics length units used to enlarge moving-body broadphase bounds."
	^ broadphaseAABBMargin
]

{ #category : 'broadphase' }
CFPhysicsStep >> broadphaseAABBMargin: aNumber [
	broadphaseAABBMargin := aNumber asFloat max: 0.0
]

