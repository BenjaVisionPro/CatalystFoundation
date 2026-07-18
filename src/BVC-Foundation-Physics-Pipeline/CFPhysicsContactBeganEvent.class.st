Class {
	#name : 'CFPhysicsContactBeganEvent',
	#superclass : 'CFPhysicsContactEvent',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsContactBeganEvent >> manifold [ ^ contact manifold ]

{ #category : 'testing' }
CFPhysicsContactBeganEvent >> began [ ^ true ]
