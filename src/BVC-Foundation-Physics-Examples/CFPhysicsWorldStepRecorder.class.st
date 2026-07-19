"
I am a small executable-example collaborator for CFPhysicsWorldBehaviour.

I expose the CFPhysicsWorld protocol used by that Behaviour and record synchronisation and fixed-step calls. I exist only to make frame-to-step accumulation observable without coupling the example to solver outcomes.
"
Class {
	#name : 'CFPhysicsWorldStepRecorder',
	#superclass : 'Object',
	#instVars : [ 'owner', 'stepDuration', 'stepCount', 'synchronisationCount', 'presentationCount' ],
	#category : 'BVC-Foundation-Physics-Examples',
	#package : 'BVC-Foundation-Physics-Examples'
}

{ #category : 'initialization' }
CFPhysicsWorldStepRecorder >> initialize [
	super initialize.
	stepDuration := 16 milliSeconds.
	stepCount := 0.
	synchronisationCount := 0.
	presentationCount := 0
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

{ #category : 'membership' }
CFPhysicsWorldStepRecorder >> synchroniseMembership [
	synchronisationCount := synchronisationCount + 1
]

{ #category : 'accessing' }
CFPhysicsWorldStepRecorder >> synchronisationCount [ ^ synchronisationCount ]


{ #category : 'presenting' }
CFPhysicsWorldStepRecorder >> present [
	presentationCount := presentationCount + 1
]

{ #category : 'accessing' }
CFPhysicsWorldStepRecorder >> presentationCount [ ^ presentationCount ]

