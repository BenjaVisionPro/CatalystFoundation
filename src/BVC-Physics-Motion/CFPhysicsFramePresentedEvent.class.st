"
I announce meaningful diagnostic changes observed while a Physics world presents through Motion.

I distinguish body presentation changes, committed contact diagnostic changes and Behaviour collection changes so observers can refresh only the affected surfaces.
"
Class {
	#name : 'CFPhysicsFramePresentedEvent',
	#superclass : 'BlEvent',
	#instVars : [ 'presentationChanged', 'contactStateChanged', 'behaviourChanged' ],
	#category : 'BVC-Physics-Motion',
	#package : 'BVC-Physics-Motion'
}

{ #category : 'instance creation' }
CFPhysicsFramePresentedEvent class >> presentationChanged: presentationBoolean contactStateChanged: contactBoolean behaviourChanged: behaviourBoolean [
	^ self new
		presentationChanged: presentationBoolean;
		contactStateChanged: contactBoolean;
		behaviourChanged: behaviourBoolean;
		yourself
]

{ #category : 'initialization' }
CFPhysicsFramePresentedEvent >> initialize [
	super initialize.
	presentationChanged := true.
	contactStateChanged := true.
	behaviourChanged := true
]

{ #category : 'testing' }
CFPhysicsFramePresentedEvent >> presentationChanged [ ^ presentationChanged ]

{ #category : 'accessing' }
CFPhysicsFramePresentedEvent >> presentationChanged: aBoolean [ presentationChanged := aBoolean ]

{ #category : 'testing' }
CFPhysicsFramePresentedEvent >> contactStateChanged [ ^ contactStateChanged ]

{ #category : 'accessing' }
CFPhysicsFramePresentedEvent >> contactStateChanged: aBoolean [ contactStateChanged := aBoolean ]

{ #category : 'testing' }
CFPhysicsFramePresentedEvent >> behaviourChanged [ ^ behaviourChanged ]

{ #category : 'accessing' }
CFPhysicsFramePresentedEvent >> behaviourChanged: aBoolean [ behaviourChanged := aBoolean ]
