"
I represent a graph-level Physics Behaviour owned by a CFPhysicsMondrian facade.

My responsibility is to participate in world updates and remove every graph resource I install when my lifecycle ends.
"
Class {
	#name : 'CFPhysicsMondrianBehaviour',
	#superclass : 'Object',
	#instVars : [ 'physics', 'world', 'removed' ],
	#category : 'BVC-Physics-Mondrian',
	#package : 'BVC-Physics-Mondrian'
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
