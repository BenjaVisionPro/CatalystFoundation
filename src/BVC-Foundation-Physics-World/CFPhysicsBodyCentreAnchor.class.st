Class {
	#name : 'CFPhysicsBodyCentreAnchor',
	#superclass : 'CFPhysicsAnchor',
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
}

{ #category : 'geometry' }
CFPhysicsBodyCentreAnchor >> worldPoint [
	^ self body position + (self body extent / 2.0)
]
