"
I am a small executable-example collaborator for CFPhysicsWorldBehaviour.

I expose only the simulation protocol used by that Behaviour and record fixed-step calls. Presentation is supplied by a separate collaborator so the examples preserve the production boundary.
"
Class {
	#name : 'CFPhysicsWorldStepRecorder',
	#superclass : 'Object',
	#instVars : [ 'owner', 'stepDuration', 'stepCount' ],
	#category : 'BVC-Foundation-Physics-Examples',
	#package : 'BVC-Foundation-Physics-Examples'
}

{ #category : 'initialization' }
CFPhysicsWorldStepRecorder >> initialize [
	super initialize.
	stepDuration := 16 milliSeconds.
	stepCount := 0
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
