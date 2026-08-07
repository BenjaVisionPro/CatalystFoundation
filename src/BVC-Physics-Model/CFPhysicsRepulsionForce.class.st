"
I repel two Physics endpoints away from each other.
"
Class {
	#name : 'CFPhysicsRepulsionForce',
	#superclass : 'CFPhysicsPairForce',
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'stepping' }
CFPhysicsRepulsionForce >> directionFor: displacement distance: distance [
	^ (displacement / distance) negated
]
