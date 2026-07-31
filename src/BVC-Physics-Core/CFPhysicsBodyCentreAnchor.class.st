Class {
	#name : 'CFPhysicsBodyCentreAnchor',
	#superclass : 'CFPhysicsAnchor',
	#category : 'BVC-Physics-Core',
	#package : 'BVC-Physics-Core'
}

{ #category : 'geometry' }
CFPhysicsBodyCentreAnchor >> worldPoint [
	^ self body worldPointForBodyLocalPoint: 0 @ 0
]
