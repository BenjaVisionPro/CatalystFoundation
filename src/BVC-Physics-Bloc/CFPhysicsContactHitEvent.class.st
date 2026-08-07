"
I announce a committed Physics contact impact to one participating Bloc element.
"
Class {
	#name : 'CFPhysicsContactHitEvent',
	#superclass : 'BlEvent',
	#instVars : [ 'record', 'body' ],
	#category : 'BVC-Physics-Bloc',
	#package : 'BVC-Physics-Bloc'
}

{ #category : 'instance creation' }
CFPhysicsContactHitEvent class >> record: aHitRecord forBody: aBody [
	^ self new
		record: aHitRecord;
		body: aBody;
		yourself
]

{ #category : 'accessing' }
CFPhysicsContactHitEvent >> approachSpeed [ ^ record approachSpeed ]

{ #category : 'accessing' }
CFPhysicsContactHitEvent >> body [ ^ body ]

{ #category : 'private - accessing' }
CFPhysicsContactHitEvent >> body: aBody [ body := aBody ]

{ #category : 'accessing' }
CFPhysicsContactHitEvent >> contact [ ^ record contact ]

{ #category : 'accessing' }
CFPhysicsContactHitEvent >> element [ ^ body element ]

{ #category : 'accessing' }
CFPhysicsContactHitEvent >> featureId [ ^ record featureId ]

{ #category : 'testing' }
CFPhysicsContactHitEvent >> isSensor [ ^ self contact isSensor ]

{ #category : 'testing' }
CFPhysicsContactHitEvent >> isSolid [ ^ self contact isSolid ]

{ #category : 'accessing' }
CFPhysicsContactHitEvent >> normal [ ^ record normal ]

{ #category : 'accessing' }
CFPhysicsContactHitEvent >> normalImpulse [ ^ record normalImpulse ]

{ #category : 'accessing' }
CFPhysicsContactHitEvent >> otherBody [
	^ self contact firstBody == body
		ifTrue: [ self contact secondBody ]
		ifFalse: [ self contact firstBody ]
]

{ #category : 'accessing' }
CFPhysicsContactHitEvent >> otherElement [ ^ self otherBody element ]

{ #category : 'accessing' }
CFPhysicsContactHitEvent >> position [ ^ record position ]

{ #category : 'private - accessing' }
CFPhysicsContactHitEvent >> record: aHitRecord [ record := aHitRecord ]
