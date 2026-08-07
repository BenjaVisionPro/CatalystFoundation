"
I announce that a contact has ended. I preserve the final contact identity for observers of the simulation.
"

Class {
	#name : 'CFPhysicsContactEndedRecord',
	#superclass : 'CFPhysicsContactEventRecord',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsContactEndedRecord >> manifold [ ^ contact previousManifold ]

{ #category : 'testing' }
CFPhysicsContactEndedRecord >> ended [ ^ true ]
