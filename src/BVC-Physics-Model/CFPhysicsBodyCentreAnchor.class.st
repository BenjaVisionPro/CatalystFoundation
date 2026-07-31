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
