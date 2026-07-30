Class {
	#name : 'CFPhysicsBodyCentreAnchor',
	#superclass : 'CFPhysicsAnchor',
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'geometry' }
CFPhysicsBodyCentreAnchor >> worldPoint [
	^ self body worldPointForBodyLocalPoint: 0 @ 0
]
