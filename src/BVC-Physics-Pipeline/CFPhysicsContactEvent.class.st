"
I represent a lifecycle event for a contact. I provide the shared protocol used by began and ended contact events.
"

Class {
	#name : 'CFPhysicsContactEvent',
	#superclass : 'Object',
	#instVars : [ 'contact' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContactEvent class >> contact: aContact [
	^ self new contact: aContact; yourself
]

{ #category : 'accessing' }
CFPhysicsContactEvent >> contact [ ^ contact ]

{ #category : 'accessing' }
CFPhysicsContactEvent >> contact: aContact [ contact := aContact ]

{ #category : 'accessing' }
CFPhysicsContactEvent >> pair [ ^ contact pair ]

{ #category : 'accessing' }
CFPhysicsContactEvent >> key [ ^ contact key ]

{ #category : 'accessing' }
CFPhysicsContactEvent >> firstBody [ ^ contact firstBody ]

{ #category : 'accessing' }
CFPhysicsContactEvent >> secondBody [ ^ contact secondBody ]

{ #category : 'testing' }
CFPhysicsContactEvent >> began [ ^ false ]

{ #category : 'testing' }
CFPhysicsContactEvent >> ended [ ^ false ]

{ #category : 'ordering' }
CFPhysicsContactEvent >> comesBefore: anotherEvent [
	self key = anotherEvent key ifTrue: [
		^ self began and: [ anotherEvent ended ] ].
	^ self pair comesBefore: anotherEvent pair
]


{ #category : 'testing' }
CFPhysicsContactEvent >> isSensor [
	^ contact isSensor
]

{ #category : 'testing' }
CFPhysicsContactEvent >> isSolid [
	^ contact isSolid
]
