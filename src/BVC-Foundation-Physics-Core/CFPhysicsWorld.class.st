Class {
	#name : 'CFPhysicsWorld',
	#superclass : 'Object',
	#instVars : [ 'owner', 'members', 'bodyStates', 'gravity', 'stepDuration', 'contacts', 'nextBodySequence' ],
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

{ #category : 'body states' }
CFPhysicsWorld >> bodyStatesInOrder [
	^ bodyStates values sorted: [ :first :second |
		first sequence < second sequence ]
]

{ #category : 'membership' }
CFPhysicsWorld >> collectMembersFrom: anElement into: aSet [
	| physics |
	physics := anElement physics.
	physics owningWorld == self ifTrue: [ aSet add: anElement ].
	physics isWorld ifTrue: [ ^ self ].
	anElement children do: [ :each |
		self collectMembersFrom: each into: aSet ]
]

{ #category : 'collision' }
CFPhysicsWorld >> contacts [
	^ contacts asArray
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
	contacts := OrderedCollection new.
	nextBodySequence := 1.
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

{ #category : 'body states' }
CFPhysicsWorld >> registerBodyFor: anElement [
	| body |
	body := CFPhysicsBodyState element: anElement world: self.
	body sequence: nextBodySequence.
	nextBodySequence := nextBodySequence + 1.
	^ body
]

{ #category : 'membership' }
CFPhysicsWorld >> retireBodiesAbsentFrom: currentMembers [
	(bodyStates keys reject: [ :each | currentMembers includes: each ]) do: [ :each |
		(bodyStates removeKey: each) release ]
]

{ #category : 'collision' }
CFPhysicsWorld >> resolveRectangleContactsAmong: bodies [
	contacts := OrderedCollection new.
	1 to: bodies size do: [ :firstIndex |
		firstIndex + 1 to: bodies size do: [ :secondIndex |
			| first second contact |
			first := bodies at: firstIndex.
			second := bodies at: secondIndex.
			(first isStatic and: [ second isStatic ]) ifFalse: [
				contact := CFPhysicsRectangleCollision
					contactBetween: first
					and: second.
				contact ifNotNil: [
					contacts add: contact.
					contact resolve ] ] ] ]
]

{ #category : 'stepping' }
CFPhysicsWorld >> step [
	| seconds bodies |
	self synchroniseMembership.
	seconds := stepDuration asMilliSeconds / 1000.0.
	bodies := self bodyStatesInOrder.
	bodies do: [ :each |
		each advanceBy: seconds gravity: gravity ].
	self resolveRectangleContactsAmong: bodies.
	bodies do: [ :each | each present ].
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
			self registerBodyFor: each ]) present ].
	members := currentMembers.
	^ members
]
