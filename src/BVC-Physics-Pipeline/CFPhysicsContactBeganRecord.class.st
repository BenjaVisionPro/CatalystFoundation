"
I announce that a contact has begun. I expose the contact and its manifold through the common contact-event protocol.
"

Class {
	#name : 'CFPhysicsContactBeganRecord',
	#superclass : 'CFPhysicsContactEventRecord',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsContactBeganRecord >> manifold [ ^ contact manifold ]

{ #category : 'testing' }
CFPhysicsContactBeganRecord >> began [ ^ true ]
