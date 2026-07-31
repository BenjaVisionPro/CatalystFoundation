Class {
	#name : 'CFPhysicsContactBeganEvent',
	#superclass : 'CFPhysicsContactEvent',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsContactBeganEvent >> manifold [ ^ contact manifold ]

{ #category : 'testing' }
CFPhysicsContactBeganEvent >> began [ ^ true ]
