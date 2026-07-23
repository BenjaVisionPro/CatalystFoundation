"
I am a small deterministic random source for Physics Behaviours.

The same non-zero seed produces the same #next sequence. Behaviours accept any source answering #next, so tests and applications may inject another deterministic source.
"
Class {
	#name : 'CFPhysicsRandomSource',
	#superclass : 'Object',
	#instVars : [ 'state' ],
	#category : 'BVC-Foundation-Physics-Core-Behaviours',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsRandomSource class >> seed: anInteger [
	^ self new seed: anInteger; yourself
]

{ #category : 'initialization' }
CFPhysicsRandomSource >> initialize [
	super initialize.
	self seed: 1
]

{ #category : 'accessing' }
CFPhysicsRandomSource >> seed: anInteger [
	state := anInteger abs \\ 2147483647.
	state isZero ifTrue: [ state := 1 ]
]

{ #category : 'accessing' }
CFPhysicsRandomSource >> next [
	state := (state * 48271) \\ 2147483647.
	^ state asFloat / 2147483647.0
]
