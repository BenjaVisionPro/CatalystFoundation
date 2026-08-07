"
I announce that a committed Physics contact ended for one Bloc element.
"
Class {
	#name : 'CFPhysicsContactEndedEvent',
	#superclass : 'CFPhysicsContactEvent',
	#category : 'BVC-Physics-Bloc',
	#package : 'BVC-Physics-Bloc'
}

{ #category : 'testing' }
CFPhysicsContactEndedEvent >> ended [ ^ true ]

{ #category : 'accessing' }
CFPhysicsContactEndedEvent >> manifold [ ^ contact previousManifold ]
