"
I represent the thresholds used to decide when bodies may sleep.

My responsibility is to keep the island sleep time and Box2D position-correction weighting together.
"
Class {
	#name : 'CFPhysicsSleepConfiguration',
	#superclass : 'Object',
	#instVars : [ 'timeToSleep', 'positionCorrectionFactor' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsSleepConfiguration class >> standard [
	^ self new
		timeToSleep: 0.5;
		positionCorrectionFactor: 0.5;
		yourself
]

{ #category : 'accessing' }
CFPhysicsSleepConfiguration >> timeToSleep [ ^ timeToSleep ]

{ #category : 'accessing' }
CFPhysicsSleepConfiguration >> timeToSleep: aNumber [
	timeToSleep := aNumber asFloat max: 0.0
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
	^ (aStepState
		sleepVelocityForElapsed: seconds
		positionCorrectionFactor: positionCorrectionFactor)
		<= aStepState sleepThreshold
]
