"
I represent a mutable scalar shared by several Physics collaborators.

My responsibility is to let related Forces and Behaviours observe one live configuration value.
"
Class {
	#name : 'CFPhysicsSharedScalar',
	#superclass : 'Object',
	#instVars : [ 'value' ],
	#category : 'BVC-Physics-Behaviours',
	#package : 'BVC-Physics-Behaviours'
}

{ #category : 'instance creation' }
CFPhysicsSharedScalar class >> value: aNumber [
	^ self new
		value: aNumber;
		yourself
]

{ #category : 'initialization' }
CFPhysicsSharedScalar >> initialize [
	super initialize.
	value := 0.0
]

{ #category : 'accessing' }
CFPhysicsSharedScalar >> value [
	^ value
]

{ #category : 'accessing' }
CFPhysicsSharedScalar >> value: aNumber [
	value := aNumber asFloat
]

