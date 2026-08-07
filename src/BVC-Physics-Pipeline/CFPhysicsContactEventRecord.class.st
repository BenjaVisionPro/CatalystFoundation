"
I represent a lifecycle event for a contact. I provide the shared protocol used by began and ended contact events.
"

Class {
	#name : 'CFPhysicsContactEventRecord',
	#superclass : 'Object',
	#instVars : [ 'contact' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContactEventRecord class >> contact: aContact [
	^ self new contact: aContact; yourself
]

{ #category : 'accessing' }
CFPhysicsContactEventRecord >> contact [ ^ contact ]

{ #category : 'accessing' }
CFPhysicsContactEventRecord >> contact: aContact [ contact := aContact ]

{ #category : 'accessing' }
CFPhysicsContactEventRecord >> pair [ ^ contact pair ]

{ #category : 'accessing' }
CFPhysicsContactEventRecord >> key [ ^ contact key ]

{ #category : 'accessing' }
CFPhysicsContactEventRecord >> firstBody [ ^ contact firstBody ]

{ #category : 'accessing' }
CFPhysicsContactEventRecord >> secondBody [ ^ contact secondBody ]

{ #category : 'testing' }
CFPhysicsContactEventRecord >> began [ ^ false ]

{ #category : 'testing' }
CFPhysicsContactEventRecord >> ended [ ^ false ]

{ #category : 'ordering' }
CFPhysicsContactEventRecord >> comesBefore: anotherEvent [
	self key = anotherEvent key ifTrue: [
		^ self began and: [ anotherEvent ended ] ].
	^ self pair comesBefore: anotherEvent pair
]


{ #category : 'testing' }
CFPhysicsContactEventRecord >> isSensor [
	^ contact isSensor
]

{ #category : 'testing' }
CFPhysicsContactEventRecord >> isSolid [
	^ contact isSolid
]
