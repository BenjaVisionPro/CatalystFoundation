"
I represent an anchor at a body's origin.

My responsibility is to follow that origin as the body moves and rotates.
"
Class {
	#name : 'CFPhysicsBodyCentreAnchor',
	#superclass : 'CFPhysicsAnchor',
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'geometry' }
CFPhysicsBodyCentreAnchor >> worldPoint [
	^ self body worldPointForBodyLocalPoint: 0 @ 0
]
