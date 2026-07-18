Class {
	#name : 'CFPhysicsPointerDragHandler',
	#superclass : 'Object',
	#instVars : [ 'element', 'constraint', 'dragStartHandler', 'dragHandler', 'dragEndHandler' ],
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
}

{ #category : 'instance creation' }
CFPhysicsPointerDragHandler class >> on: anElement [
	^ self new
		installOn: anElement;
		yourself
]

{ #category : 'accessing' }
CFPhysicsPointerDragHandler >> element [ ^ element ]

{ #category : 'accessing' }
CFPhysicsPointerDragHandler >> constraint [ ^ constraint ]

{ #category : 'lifecycle' }
CFPhysicsPointerDragHandler >> installOn: anElement [
	element ifNotNil: [ self uninstall ].
	element := anElement.
	dragStartHandler := BlEventHandler on: BlDragStartEvent do: [ :anEvent |
		anEvent isPrimaryButtonDrag ifTrue: [ self beginFrom: anEvent ] ].
	dragHandler := BlEventHandler on: BlDragEvent do: [ :anEvent |
		anEvent isPrimaryButtonDrag ifTrue: [ self continueFrom: anEvent ] ].
	dragEndHandler := BlEventHandler on: BlDragEndEvent do: [ :anEvent |
		anEvent isPrimaryButtonDrag ifTrue: [ self endFrom: anEvent ] ].
	element addEventHandler: dragStartHandler.
	element addEventHandler: dragHandler.
	element addEventHandler: dragEndHandler
]

{ #category : 'events' }
CFPhysicsPointerDragHandler >> beginFrom: anEvent [
	| world body pointer |
	world := element physics world.
	world ifNil: [ ^ self ].
	world synchroniseMembership.
	body := element physics bodyState.
	(body isNil or: [ body isDynamic not ]) ifTrue: [ ^ self ].
	pointer := self worldPointFor: anEvent position in: world.
	constraint := CFPhysicsPointerConstraint
		body: body
		pointerPosition: pointer
		timestamp: anEvent timestamp.
	world addPointerConstraint: constraint
]

{ #category : 'events' }
CFPhysicsPointerDragHandler >> continueFrom: anEvent [
	constraint ifNil: [ ^ self ].
	constraint
		updatePointerPosition: (self worldPointFor: anEvent position in: constraint body world)
		timestamp: anEvent timestamp
]

{ #category : 'events' }
CFPhysicsPointerDragHandler >> endFrom: anEvent [
	constraint ifNil: [ ^ self ].
	constraint
		updatePointerPosition: (self worldPointFor: anEvent position in: constraint body world)
		timestamp: anEvent timestamp.
	constraint body world removePointerConstraint: constraint.
	constraint := nil
]

{ #category : 'private' }
CFPhysicsPointerDragHandler >> worldPointFor: aGlobalPoint in: aWorld [
	^ aWorld owner globalPointToLocal: aGlobalPoint
]

{ #category : 'lifecycle' }
CFPhysicsPointerDragHandler >> uninstall [
	constraint ifNotNil: [
		constraint body world removePointerConstraint: constraint.
		constraint := nil ].
	element ifNotNil: [
		{ dragStartHandler. dragHandler. dragEndHandler } do: [ :each |
			each ifNotNil: [ element removeEventHandler: each ] ] ].
	dragStartHandler := nil.
	dragHandler := nil.
	dragEndHandler := nil.
	element := nil
]
