"
I am a small executable-example collaborator for CFPhysicsWorldMotionBehaviour.

I expose only the simulation protocol used by that Behaviour and record fixed-step calls. Presentation is supplied by a separate collaborator so the examples preserve the production boundary.
"
Class {
	#name : 'CFPhysicsWorldStepRecorder',
	#superclass : 'Object',
	#instVars : [ 'owner', 'stepDuration', 'stepCount', 'backgroundStepping', 'backgroundStepCount', 'solveInFlight' ],
	#category : 'BVC-Foundation-Physics-Examples',
	#package : 'BVC-Foundation-Physics-Examples'
}

{ #category : 'initialization' }
CFPhysicsWorldStepRecorder >> initialize [
	super initialize.
	stepDuration := 16 milliSeconds.
	stepCount := 0.
	backgroundStepping := false.
	backgroundStepCount := 0.
	solveInFlight := false
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
CFPhysicsWorldStepRecorder >> backgroundStepping: aBoolean [
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

