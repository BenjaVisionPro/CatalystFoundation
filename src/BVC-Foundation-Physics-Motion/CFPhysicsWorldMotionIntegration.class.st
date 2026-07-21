"
I own the optional Motion integration state associated with one CFPhysicsWorld.

The Physics world retains no Motion-specific instance variables. My class-side weak association supplies one integration per world while this package is loaded. I own both the reusable continuous playback capability and the lazily created manual presentation.

Changing the world owner asks me to release the complete integration lifetime before the new owner is installed.
"
Class {
	#name : 'CFPhysicsWorldMotionIntegration',
	#superclass : 'Object',
	#instVars : [ 'world', 'playback', 'manualPresentation', 'lifecycleHandler' ],
	#classVars : [ 'Associations' ],
	#category : 'BVC-Foundation-Physics-Motion',
	#package : 'BVC-Foundation-Physics-Motion'
}

{ #category : 'private - accessing' }
CFPhysicsWorldMotionIntegration class >> associations [
	^ Associations ifNil: [ Associations := WeakIdentityKeyDictionary new ]
]

{ #category : 'instance creation' }
CFPhysicsWorldMotionIntegration class >> for: aWorld [
	^ self associations
		at: aWorld
		ifAbsentPut: [ self new world: aWorld; yourself ]
]

{ #category : 'accessing' }
CFPhysicsWorldMotionIntegration class >> existingFor: aWorld [
	^ self associations at: aWorld ifAbsent: [ nil ]
]

{ #category : 'lifecycle' }
CFPhysicsWorldMotionIntegration class >> releaseFor: aWorld [
	| integration |
	integration := self associations removeKey: aWorld ifAbsent: [ nil ].
	integration ifNotNil: #release
]

{ #category : 'private - initialization' }
CFPhysicsWorldMotionIntegration >> world: aWorld [
	world := aWorld.
	self installLifecycleHandler
]

{ #category : 'private - lifecycle' }
CFPhysicsWorldMotionIntegration >> installLifecycleHandler [
	| owner |
	owner := world owner.
	owner ifNil: [ ^ self ].
	lifecycleHandler ifNil: [
		lifecycleHandler := CFPhysicsWorldLifecycleHandler on: world.
		owner addEventHandler: lifecycleHandler ]
]

{ #category : 'private - presenting' }
CFPhysicsWorldMotionIntegration >> manualPresentation [
	self isStepping ifTrue: [
		self error: 'Manual Physics presentation is unavailable during continuous stepping' ].
	^ manualPresentation ifNil: [
		manualPresentation := CFPhysicsWorldPresentation on: world ]
]

{ #category : 'presenting' }
CFPhysicsWorldMotionIntegration >> present [
	self manualPresentation present
]

{ #category : 'presenting' }
CFPhysicsWorldMotionIntegration >> presentAtAlpha: aNumber [
	self manualPresentation presentAtAlpha: aNumber
]

{ #category : 'presenting' }
CFPhysicsWorldMotionIntegration >> stepAndPresent [
	| result presentation |
	presentation := self manualPresentation.
	result := world step.
	presentation present.
	^ result
]

{ #category : 'continuous stepping' }
CFPhysicsWorldMotionIntegration >> startStepping [
	self releaseManualPresentation.
	^ self playback start
]

{ #category : 'continuous stepping' }
CFPhysicsWorldMotionIntegration >> pauseStepping [
	playback ifNotNil: #pause
]

{ #category : 'continuous stepping' }
CFPhysicsWorldMotionIntegration >> resumeStepping [
	playback ifNotNil: #resume
]

{ #category : 'continuous stepping' }
CFPhysicsWorldMotionIntegration >> stopStepping [
	playback ifNotNil: #stop
]

{ #category : 'testing' }
CFPhysicsWorldMotionIntegration >> isStepping [
	^ playback notNil and: [ playback isActive ]
]

{ #category : 'private - continuous stepping' }
CFPhysicsWorldMotionIntegration >> playback [
	^ playback ifNil: [ playback := CFPhysicsWorldPlayback on: world ]
]

{ #category : 'private - lifecycle' }
CFPhysicsWorldMotionIntegration >> releaseManualPresentation [
	manualPresentation ifNotNil: #release.
	manualPresentation := nil
]

{ #category : 'lifecycle' }
CFPhysicsWorldMotionIntegration >> release [
	playback ifNotNil: #stop.
	playback := nil.
	self releaseManualPresentation.
	lifecycleHandler ifNotNil: [
		world owner ifNotNil: [ :anOwner | anOwner removeEventHandler: lifecycleHandler ].
		lifecycleHandler := nil ]
]
