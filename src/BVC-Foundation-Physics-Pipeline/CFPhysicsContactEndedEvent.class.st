Class {
	#name : 'CFPhysicsContactEndedEvent',
	#superclass : 'CFPhysicsContactEvent',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsContactEndedEvent >> manifold [ ^ contact previousManifold ]

{ #category : 'testing' }
CFPhysicsContactEndedEvent >> ended [ ^ true ]
