"
I attract two Physics endpoints toward each other.
"
Class {
	#name : 'CFPhysicsAttractionForce',
	#superclass : 'CFPhysicsPairForce',
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'stepping' }
CFPhysicsAttractionForce >> directionFor: displacement distance: distance [
	^ displacement / distance
]
