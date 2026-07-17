Class {
	#name : 'CFPhysicsWorld',
	#superclass : 'Object',
	#instVars : [ 'owner', 'members' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsWorld class >> on: anElement [
	^ self new
		owner: anElement;
		yourself
]

{ #category : 'testing' }
CFPhysicsWorld >> includes: anElement [
	^ members includes: anElement
]

{ #category : 'initialization' }
CFPhysicsWorld >> initialize [
	super initialize.
	members := IdentitySet new
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
CFPhysicsWorld >> synchroniseMembership [
	| currentMembers |
	currentMembers := IdentitySet new.
	owner children do: [ :each |
		self collectMembersFrom: each into: currentMembers ].
	members := currentMembers.
	^ members
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
