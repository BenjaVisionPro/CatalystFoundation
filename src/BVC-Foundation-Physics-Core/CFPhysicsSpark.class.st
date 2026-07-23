Class {
	#name : 'CFPhysicsSpark',
	#superclass : 'Object',
	#instVars : [ 'element', 'emittedAt', 'expiresAt', 'launched' ],
	#category : 'BVC-Foundation-Physics-Core-Behaviours',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsSpark class >> element: anElement emittedAt: emissionTime expiresAt: expiryTime [
	^ self new
		element: anElement;
		emittedAt: emissionTime;
		expiresAt: expiryTime;
		yourself
]

{ #category : 'initialization' }
CFPhysicsSpark >> initialize [
	super initialize.
	launched := false
]

{ #category : 'accessing' }
CFPhysicsSpark >> element [
	^ element
]

{ #category : 'private - initialization' }
CFPhysicsSpark >> element: anElement [
	element := anElement
]

{ #category : 'accessing' }
CFPhysicsSpark >> emittedAt [
	^ emittedAt
]

{ #category : 'private - initialization' }
CFPhysicsSpark >> emittedAt: aNumber [
	emittedAt := aNumber
]

{ #category : 'accessing' }
CFPhysicsSpark >> expiresAt [
	^ expiresAt
]

{ #category : 'private - initialization' }
CFPhysicsSpark >> expiresAt: aNumber [
	expiresAt := aNumber
]

{ #category : 'testing' }
CFPhysicsSpark >> isLaunched [
	^ launched
]

{ #category : 'launching' }
CFPhysicsSpark >> beLaunched [
	launched := true
]

{ #category : 'testing' }
CFPhysicsSpark >> isExpiredAt: simulationTime [
	^ simulationTime >= expiresAt
]
