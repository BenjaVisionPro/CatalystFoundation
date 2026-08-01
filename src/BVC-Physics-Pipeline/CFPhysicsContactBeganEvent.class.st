"
I announce that a contact has begun. I expose the contact and its manifold through the common contact-event protocol.
"

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
