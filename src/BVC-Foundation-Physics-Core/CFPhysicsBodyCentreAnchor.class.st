Class {
	#name : 'CFPhysicsBodyCentreAnchor',
	#superclass : 'CFPhysicsAnchor',
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'geometry' }
CFPhysicsBodyCentreAnchor >> worldPoint [
	^ self body position + (self body extent / 2.0)
]
