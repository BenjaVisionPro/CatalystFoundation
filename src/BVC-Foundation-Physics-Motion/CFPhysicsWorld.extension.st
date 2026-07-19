Extension { #name : 'CFPhysicsWorld' }

{ #category : '*BVC-Foundation-Physics-Motion - private - presenting' }
CFPhysicsWorld >> presentation [
	self isStepping ifTrue: [
		self error: 'Manual Physics presentation is unavailable during continuous stepping' ].
	^ presentation ifNil: [
		presentation := CFPhysicsWorldPresentation on: self ]
]

{ #category : '*BVC-Foundation-Physics-Motion - private - presenting' }
CFPhysicsWorld >> releasePresentation [
	presentation ifNotNil: [ :aPresentation | aPresentation release ].
	presentation := nil
]

{ #category : '*BVC-Foundation-Physics-Motion - presenting' }
CFPhysicsWorld >> present [
	self presentation present.
	^ self
]

{ #category : '*BVC-Foundation-Physics-Motion - presenting' }
CFPhysicsWorld >> presentAtAlpha: aNumber [
	self presentation presentAtAlpha: aNumber.
	^ self
]

{ #category : '*BVC-Foundation-Physics-Motion - stepping' }
CFPhysicsWorld >> stepAndPresent [
	| result manualPresentation |
	manualPresentation := self presentation.
	result := self step.
	manualPresentation present.
	^ result
]

{ #category : '*BVC-Foundation-Physics-Motion - continuous stepping' }
CFPhysicsWorld >> startStepping [
	^ self playback start
]

{ #category : '*BVC-Foundation-Physics-Motion - continuous stepping' }
CFPhysicsWorld >> pauseStepping [
	playback ifNotNil: [ :aPlayback | aPlayback pause ].
	^ self
]

{ #category : '*BVC-Foundation-Physics-Motion - continuous stepping' }
CFPhysicsWorld >> resumeStepping [
	playback ifNotNil: [ :aPlayback | aPlayback resume ].
	^ self
]

{ #category : '*BVC-Foundation-Physics-Motion - continuous stepping' }
CFPhysicsWorld >> stopStepping [
	playback ifNotNil: [ :aPlayback | aPlayback stop ].
	^ self
]

{ #category : '*BVC-Foundation-Physics-Motion - continuous stepping' }
CFPhysicsWorld >> steppingMotion [
	^ playback ifNil: [ nil ] ifNotNil: [ :aPlayback | aPlayback motion ]
]

{ #category : '*BVC-Foundation-Physics-Motion - testing' }
CFPhysicsWorld >> isStepping [
	^ playback notNil and: [ playback isActive ]
]

{ #category : '*BVC-Foundation-Physics-Motion - private - continuous stepping' }
CFPhysicsWorld >> playback [
	^ playback ifNil: [ playback := CFPhysicsWorldPlayback on: self ]
]
