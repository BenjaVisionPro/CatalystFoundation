"
I represent a policy that maps distance to force magnitude.

My responsibility is to let interactions vary their response without owning the bodies they affect.
"
Class {
	#name : 'CFPhysicsDistanceResponse',
	#superclass : 'Object',
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'evaluating' }
CFPhysicsDistanceResponse >> forceMagnitudeAtDistance: aNumber [
	self subclassResponsibility
]
