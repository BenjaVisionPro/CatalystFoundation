Class {
	#name : 'CFPhysicsContactManager',
	#superclass : 'Object',
	#instVars : [ 'contactsByKey', 'endedContacts' ],
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'accessing' }
CFPhysicsContactManager >> contacts [
	^ contactsByKey values sorted: [ :first :second |
		first firstBody sequence < second firstBody sequence or: [
			first firstBody sequence = second firstBody sequence and: [
				first secondBody sequence < second secondBody sequence ] ] ]
]

{ #category : 'private' }
CFPhysicsContactManager >> contactFirstBodyFrom: first second: second [
	(first isStatic and: [ second isDynamic ]) ifTrue: [ ^ second ].
	^ first sequence < second sequence
		ifTrue: [ first ]
		ifFalse: [ second ]
]

{ #category : 'private' }
CFPhysicsContactManager >> contactSecondBodyFrom: first second: second [
	| contactFirst |
	contactFirst := self contactFirstBodyFrom: first second: second.
	^ contactFirst == first ifTrue: [ second ] ifFalse: [ first ]
]

{ #category : 'accessing' }
CFPhysicsContactManager >> endedContacts [
	^ endedContacts asArray
]

{ #category : 'initialization' }
CFPhysicsContactManager >> initialize [
	super initialize.
	contactsByKey := Dictionary new.
	endedContacts := OrderedCollection new
]

{ #category : 'removing' }
CFPhysicsContactManager >> removeBody: aBody [
	| keys |
	keys := contactsByKey keys select: [ :each |
		(contactsByKey at: each) involves: aBody ].
	keys do: [ :each | self removeContactAt: each ]
]

{ #category : 'private' }
CFPhysicsContactManager >> removeContactAt: aKey [
	| contact |
	contact := contactsByKey removeKey: aKey.
	contact markSeparated.
	contact firstBody removeContact: contact.
	contact secondBody removeContact: contact.
	endedContacts add: contact
]

{ #category : 'updating' }
CFPhysicsContactManager >> updateBodies: bodies [
	| activeKeys |
	endedContacts := OrderedCollection new.
	activeKeys := Set new.
	1 to: bodies size do: [ :firstIndex |
		firstIndex + 1 to: bodies size do: [ :secondIndex |
			| first second contactFirst contactSecond manifold key contact |
			first := bodies at: firstIndex.
			second := bodies at: secondIndex.
			(first isStatic and: [ second isStatic ]) ifFalse: [
				contactFirst := self contactFirstBodyFrom: first second: second.
				contactSecond := self contactSecondBodyFrom: first second: second.
				manifold := CFPhysicsCollision
					manifoldBetween: contactFirst
					and: contactSecond.
				manifold ifNotNil: [
					key := CFPhysicsContactKey first: first second: second.
					activeKeys add: key.
					contact := contactsByKey at: key ifAbsent: [ nil ].
					contact
						ifNil: [
							contactFirst wake.
							contactSecond wake.
							contact := CFPhysicsContact
								first: contactFirst
								second: contactSecond
								manifold: manifold.
							contactsByKey at: key put: contact.
							contactFirst addContact: contact.
							contactSecond addContact: contact ]
						ifNotNil: [ contact updateWithManifold: manifold ] ] ] ] ].
	(contactsByKey keys reject: [ :each | activeKeys includes: each ]) do: [ :each |
		self removeContactAt: each ].
	^ self contacts
]


{ #category : 'solving' }
CFPhysicsContactManager >> warmStart [
	self contacts do: [ :each | each warmStart ]
]

{ #category : 'solving' }
CFPhysicsContactManager >> solveVelocityIterations: anInteger [
	anInteger timesRepeat: [
		self contacts do: [ :each | each solveVelocity ] ]
]

{ #category : 'solving' }
CFPhysicsContactManager >> solvePositionIterations: anInteger [
	| fraction |
	anInteger <= 0 ifTrue: [ ^ self ].
	fraction := 1.0 / anInteger.
	anInteger timesRepeat: [
		self contacts do: [ :each | each solvePositionFraction: fraction ] ]
]
