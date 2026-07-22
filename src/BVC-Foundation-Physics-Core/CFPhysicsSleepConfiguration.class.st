Class {
	#name : 'CFPhysicsSleepConfiguration',
	#superclass : 'Object',
	#instVars : [ 'linearVelocityThreshold', 'angularVelocityThreshold', 'timeToSleep', 'positionCorrectionFactor' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsSleepConfiguration class >> standard [
	^ self new
		linearVelocityThreshold: 5.0;
		angularVelocityThreshold: (2.0 * Float pi / 180.0);
		timeToSleep: 0.5;
		positionCorrectionFactor: 0.5;
		yourself
]

{ #category : 'accessing' }
CFPhysicsSleepConfiguration >> linearVelocityThreshold [ ^ linearVelocityThreshold ]

{ #category : 'accessing' }
CFPhysicsSleepConfiguration >> linearVelocityThreshold: aNumber [
	linearVelocityThreshold := aNumber asFloat max: 0.0
]

{ #category : 'accessing' }
CFPhysicsSleepConfiguration >> angularVelocityThreshold [ ^ angularVelocityThreshold ]

{ #category : 'accessing' }
CFPhysicsSleepConfiguration >> angularVelocityThreshold: aNumber [
	angularVelocityThreshold := aNumber asFloat max: 0.0
]

{ #category : 'accessing' }
CFPhysicsSleepConfiguration >> timeToSleep [ ^ timeToSleep ]

{ #category : 'accessing' }
CFPhysicsSleepConfiguration >> timeToSleep: aNumber [
	timeToSleep := aNumber asFloat max: 0.0
]

{ #category : 'testing' }
CFPhysicsSleepConfiguration >> acceptsLinearVelocity: aPoint angularVelocity: anAngularVelocity [
	^ (aPoint x squared + aPoint y squared) <= linearVelocityThreshold squared
		and: [ anAngularVelocity squared <= angularVelocityThreshold squared ]
]


{ #category : 'accessing' }
CFPhysicsSleepConfiguration >> positionCorrectionFactor [
	^ positionCorrectionFactor
]

{ #category : 'accessing' }
CFPhysicsSleepConfiguration >> positionCorrectionFactor: aNumber [
	positionCorrectionFactor := aNumber asFloat max: 0.0
]

{ #category : 'testing' }
CFPhysicsSleepConfiguration >> acceptsStepState: aStepState elapsed: seconds [
	| linearCorrectionVelocity angularCorrectionVelocity |
	(self
		acceptsLinearVelocity: aStepState linearVelocity
		angularVelocity: aStepState angularVelocity) ifFalse: [ ^ false ].
	seconds <= 0.0 ifTrue: [ ^ true ].
	linearCorrectionVelocity := positionCorrectionFactor * aStepState deltaPosition r / seconds.
	angularCorrectionVelocity := positionCorrectionFactor * aStepState deltaRotation abs / seconds.
	^ linearCorrectionVelocity <= linearVelocityThreshold
		and: [ angularCorrectionVelocity <= angularVelocityThreshold ]
]
