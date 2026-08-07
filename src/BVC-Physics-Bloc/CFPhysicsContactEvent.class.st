"
I announce a committed Physics contact lifecycle change to one participating Bloc element.
I orient the contact from the receiving body toward the other body.
"
Class {
	#name : 'CFPhysicsContactEvent',
	#superclass : 'BlEvent',
	#instVars : [ 'contact', 'body' ],
	#category : 'BVC-Physics-Bloc',
	#package : 'BVC-Physics-Bloc'
}

{ #category : 'instance creation' }
CFPhysicsContactEvent class >> contact: aContact forBody: aBody [
	^ self new
		contact: aContact;
		body: aBody;
		yourself
]

{ #category : 'testing' }
CFPhysicsContactEvent >> began [ ^ false ]

{ #category : 'accessing' }
CFPhysicsContactEvent >> body [ ^ body ]

{ #category : 'private - accessing' }
CFPhysicsContactEvent >> body: aBody [ body := aBody ]

{ #category : 'accessing' }
CFPhysicsContactEvent >> contact [ ^ contact ]

{ #category : 'private - accessing' }
CFPhysicsContactEvent >> contact: aContact [ contact := aContact ]

{ #category : 'accessing' }
CFPhysicsContactEvent >> element [ ^ body element ]

{ #category : 'testing' }
CFPhysicsContactEvent >> ended [ ^ false ]

{ #category : 'testing' }
CFPhysicsContactEvent >> isSensor [ ^ contact isSensor ]

{ #category : 'testing' }
CFPhysicsContactEvent >> isSolid [ ^ contact isSolid ]

{ #category : 'accessing' }
CFPhysicsContactEvent >> key [ ^ contact key ]

{ #category : 'accessing' }
CFPhysicsContactEvent >> otherBody [
	^ contact firstBody == body
		ifTrue: [ contact secondBody ]
		ifFalse: [ contact firstBody ]
]

{ #category : 'accessing' }
CFPhysicsContactEvent >> otherElement [ ^ self otherBody element ]

{ #category : 'accessing' }
CFPhysicsContactEvent >> pair [ ^ contact pair ]
