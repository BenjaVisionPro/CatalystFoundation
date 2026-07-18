Class {
	#name : 'CFPhysicsStep',
	#superclass : 'Object',
	#instVars : [ 'timeStep', 'substepCount', 'substepTime', 'inverseSubstepTime', 'contactHertz', 'contactDampingRatio', 'biasRate', 'massCoefficient', 'impulseCoefficient' ],
	#category : 'BVC-Foundation-Physics-Dynamics',
	#package : 'BVC-Foundation-Physics-Dynamics'
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
	| omega a1 a2 a3 |
	substepCount := substepCount max: 1.
	substepTime := timeStep / substepCount.
	inverseSubstepTime := substepTime = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / substepTime ].
	omega := 2.0 * Float pi * contactHertz.
	a1 := (2.0 * contactDampingRatio) + (omega * substepTime).
	a2 := substepTime * omega * a1.
	a3 := 1.0 / (1.0 + a2).
	biasRate := a1 = 0.0 ifTrue: [ 0.0 ] ifFalse: [ omega / a1 ].
	massCoefficient := a2 * a3.
	impulseCoefficient := a3
]

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
