Class {
	#name : 'CFPhysicsSharedScalar',
	#superclass : 'Object',
	#instVars : [ 'value' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
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

