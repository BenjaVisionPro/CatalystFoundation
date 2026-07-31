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
