"
I am a behaviour attached to one CFPhysicsMondrian facade.

I orchestrate graph-level Physics changes and own their complete lifecycle. I am
updated by the facade's Physics world and remove every resource I installed when
I am removed.
"
Class {
	#name : 'CFPhysicsMondrianBehaviour',
	#superclass : 'Object',
	#instVars : [ 'physics', 'world', 'removed' ],
	#category : 'BVC-Foundation-Physics-Mondrian-Behaviours',
	#package : 'BVC-Foundation-Physics-Mondrian'
}

{ #category : 'instance creation' }
CFPhysicsMondrianBehaviour class >> physics: aMondrianPhysics [
	^ self new physics: aMondrianPhysics; yourself
]

{ #category : 'initialization' }
CFPhysicsMondrianBehaviour >> initialize [ super initialize. removed := false ]

{ #category : 'accessing' }
CFPhysicsMondrianBehaviour >> physics [ ^ physics ]

{ #category : 'private - installation' }
CFPhysicsMondrianBehaviour >> physics: aMondrianPhysics [ physics := aMondrianPhysics ]

{ #category : 'accessing' }
CFPhysicsMondrianBehaviour >> world [ ^ world ]

{ #category : 'private - installation' }
CFPhysicsMondrianBehaviour >> world: aWorld [ world := aWorld ]

{ #category : 'accessing' }
CFPhysicsMondrianBehaviour >> mondrian [ ^ physics mondrian ]

{ #category : 'testing' }
CFPhysicsMondrianBehaviour >> isRemoved [ ^ removed ]

{ #category : 'testing' }
CFPhysicsMondrianBehaviour >> stillBelongsToWorld [
	^ physics notNil and: [ physics world == world ]
]

{ #category : 'updating' }
CFPhysicsMondrianBehaviour >> updateForStep: aPhysicsStep [ self subclassResponsibility ]

{ #category : 'removing' }
CFPhysicsMondrianBehaviour >> remove [
	removed ifTrue: [ ^ self ].
	removed := true.
	[ self removing ] ensure: [
		world ifNotNil: [ world removeBehaviour: self ].
		physics ifNotNil: [ physics removeBehaviour: self ] ].
	^ self
]

{ #category : 'removing' }
CFPhysicsMondrianBehaviour >> removing [ ]
