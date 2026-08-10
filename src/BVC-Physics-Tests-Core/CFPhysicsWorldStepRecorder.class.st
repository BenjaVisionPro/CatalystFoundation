"
I record the stepping protocol used by Physics Motion examples.

My responsibility is to verify fixed-step and background-step coordination without constructing a complete Physics world.
"
Class {
	#name : 'CFPhysicsWorldStepRecorder',
	#superclass : 'Object',
	#instVars : [ 'owner', 'stepDuration', 'stepCount', 'backgroundStepping', 'backgroundStepCount', 'solveInFlight', 'foregroundSteppingRequired' ],
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'initialization' }
CFPhysicsWorldStepRecorder >> initialize [
	super initialize.
	stepDuration := 16 milliSeconds.
	stepCount := 0.
	backgroundStepping := false.
	backgroundStepCount := 0.
	solveInFlight := false.
	foregroundSteppingRequired := false
]

{ #category : 'accessing' }
CFPhysicsWorldStepRecorder >> owner [ ^ owner ]

{ #category : 'accessing' }
CFPhysicsWorldStepRecorder >> owner: anElement [ owner := anElement ]

{ #category : 'stepping' }
CFPhysicsWorldStepRecorder >> step [
	stepCount := stepCount + 1
]

{ #category : 'accessing' }
CFPhysicsWorldStepRecorder >> stepCount [ ^ stepCount ]

{ #category : 'accessing' }
CFPhysicsWorldStepRecorder >> stepDuration [ ^ stepDuration ]

{ #category : 'accessing' }
CFPhysicsWorldStepRecorder >> stepDuration: aDuration [ stepDuration := aDuration ]


{ #category : 'accessing' }
CFPhysicsWorldStepRecorder >> backgroundStepping [
	^ backgroundStepping
]


{ #category : 'accessing' }
CFPhysicsWorldStepRecorder >> effectiveBackgroundStepping [
	^ backgroundStepping and: [ foregroundSteppingRequired not ]
]

{ #category : 'controlling' }
CFPhysicsWorldStepRecorder >> foregroundSteppingRequired: aBoolean [
	foregroundSteppingRequired := aBoolean
]

{ #category : 'testing' }
CFPhysicsWorldStepRecorder >> hasBackgroundExecutionInFlight [
	^ solveInFlight
]

{ #category : 'accessing' }
CFPhysicsWorldStepRecorder >> backgroundStepping: aBoolean [
	backgroundStepping = aBoolean ifTrue: [ ^ self ].
	(backgroundStepping and: [ aBoolean not ]) ifTrue: [ self abandonActiveSolve ].
	backgroundStepping := aBoolean
]

{ #category : 'stepping' }
CFPhysicsWorldStepRecorder >> startBackgroundStep [
	solveInFlight ifTrue: [ ^ false ].
	solveInFlight := true.
	backgroundStepCount := backgroundStepCount + 1.
	^ true
]

{ #category : 'accessing' }
CFPhysicsWorldStepRecorder >> backgroundStepCount [
	^ backgroundStepCount
]

{ #category : 'controlling' }
CFPhysicsWorldStepRecorder >> completeBackgroundStep [
	solveInFlight := false
]

{ #category : 'testing' }
CFPhysicsWorldStepRecorder >> hasSolveInFlight [
	^ solveInFlight
]

{ #category : 'controlling' }
CFPhysicsWorldStepRecorder >> abandonActiveSolve [
	solveInFlight := false
]

