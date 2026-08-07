"
I announce that a committed Physics contact began for one Bloc element.
"
Class {
	#name : 'CFPhysicsContactBeganEvent',
	#superclass : 'CFPhysicsContactEvent',
	#category : 'BVC-Physics-Bloc',
	#package : 'BVC-Physics-Bloc'
}

{ #category : 'testing' }
CFPhysicsContactBeganEvent >> began [ ^ true ]

{ #category : 'accessing' }
CFPhysicsContactBeganEvent >> manifold [ ^ contact manifold ]
