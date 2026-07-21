Class {
	#name : 'CFPhysicsMaterial',
	#superclass : 'Object',
	#instVars : [ 'density', 'friction', 'restitution' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'accessing' }
CFPhysicsMaterial >> density [
	^ density
]

{ #category : 'accessing' }
CFPhysicsMaterial >> density: aNumber [
	density := aNumber asFloat
]

{ #category : 'accessing' }
CFPhysicsMaterial >> friction [
	^ friction
]

{ #category : 'accessing' }
CFPhysicsMaterial >> friction: aNumber [
	friction := aNumber asFloat
]

{ #category : 'initialization' }
CFPhysicsMaterial >> initialize [
	super initialize.
	density := 1.0.
	friction := 0.5.
	restitution := 0.2
]

{ #category : 'accessing' }
CFPhysicsMaterial >> restitution [
	^ restitution
]

{ #category : 'accessing' }
CFPhysicsMaterial >> restitution: aNumber [
	restitution := aNumber asFloat
]
