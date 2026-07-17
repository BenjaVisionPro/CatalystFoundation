Class {
	#name : 'CFPhysicsWorld',
	#superclass : 'Object',
	#instVars : [ 'owner', 'members', 'bodyStates', 'gravity', 'stepDuration' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsWorld class >> on: anElement [
	^ self new
		owner: anElement;
		yourself
]

{ #category : 'body states' }
CFPhysicsWorld >> bodyStateFor: anElement [
	^ bodyStates at: anElement ifAbsent: [ nil ]
]

{ #category : 'membership' }
CFPhysicsWorld >> collectMembersFrom: anElement into: aSet [
	| physics |
	physics := anElement existingPhysics.
	physics ifNotNil: [
		physics owningWorld == self ifTrue: [ aSet add: anElement ].
		physics isWorld ifTrue: [ ^ self ] ].
	anElement children do: [ :each |
		self collectMembersFrom: each into: aSet ]
]

{ #category : 'accessing' }
CFPhysicsWorld >> gravity [
	^ gravity
]

{ #category : 'accessing' }
CFPhysicsWorld >> gravity: aPoint [
	gravity := aPoint
]

{ #category : 'testing' }
CFPhysicsWorld >> includes: anElement [
	^ members includes: anElement
]

{ #category : 'initialization' }
CFPhysicsWorld >> initialize [
	super initialize.
	members := IdentitySet new.
	bodyStates := IdentityDictionary new.
	gravity := 0 @ 1000.
	stepDuration := 16 milliseconds
]

{ #category : 'accessing' }
CFPhysicsWorld >> members [
	^ members asArray
]

{ #category : 'accessing' }
CFPhysicsWorld >> owner [
	^ owner
]

{ #category : 'accessing' }
CFPhysicsWorld >> owner: anElement [
	owner := anElement
]

{ #category : 'membership' }
CFPhysicsWorld >> retireBodiesAbsentFrom: currentMembers [
	(bodyStates keys reject: [ :each | currentMembers includes: each ]) do: [ :each |
		(bodyStates removeKey: each) release ]
]

{ #category : 'stepping' }
CFPhysicsWorld >> step [
	| seconds |
	self synchroniseMembership.
	seconds := stepDuration asMilliSeconds / 1000.0.
	bodyStates valuesDo: [ :each |
		each advanceBy: seconds gravity: gravity ].
	^ self
]

{ #category : 'stepping' }
CFPhysicsWorld >> step: aPositiveInteger [
	aPositiveInteger timesRepeat: [ self step ].
	^ self
]

{ #category : 'accessing' }
CFPhysicsWorld >> stepDuration [
	^ stepDuration
]

{ #category : 'accessing' }
CFPhysicsWorld >> stepDuration: aDuration [
	stepDuration := aDuration
]

{ #category : 'membership' }
CFPhysicsWorld >> synchroniseMembership [
	| currentMembers |
	currentMembers := IdentitySet new.
	owner children do: [ :each |
		self collectMembersFrom: each into: currentMembers ].
	self retireBodiesAbsentFrom: currentMembers.
	currentMembers do: [ :each |
		(bodyStates at: each ifAbsentPut: [
			CFPhysicsBodyState element: each world: self ]) present ].
	members := currentMembers.
	^ members
]
