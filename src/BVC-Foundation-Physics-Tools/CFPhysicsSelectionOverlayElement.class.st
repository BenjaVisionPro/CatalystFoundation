Class {
	#name : 'CFPhysicsSelectionOverlayElement',
	#superclass : 'CFPhysicsBodyOverlayElement',
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'initialization' }
CFPhysicsSelectionOverlayElement >> initializeRepresentation [
	super initializeRepresentation.
	self
		selected: true;
		zIndex: 2
]
