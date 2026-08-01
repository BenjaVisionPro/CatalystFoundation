"
I announce that a contact has ended. I preserve the final contact identity for observers of the simulation.
"

Class {
	#name : 'CFPhysicsContactEndedEvent',
	#superclass : 'CFPhysicsContactEvent',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsContactEndedEvent >> manifold [ ^ contact previousManifold ]

{ #category : 'testing' }
CFPhysicsContactEndedEvent >> ended [ ^ true ]
