Class {
	#name : 'CFPhysicsOverlay',
	#superclass : 'Object',
	#instVars : [ 'host', 'world', 'root', 'context', 'bodyElements' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsOverlay class >> on: aHostElement [
	| physics |
	physics := aHostElement existingPhysics.
	(physics notNil and: [ physics isWorld ])
		ifFalse: [ self error: 'A physics overlay requires an element that owns a physics world' ].
	^ self new
		host: aHostElement;
		world: physics existingWorld;
		initializeOverlay;
		yourself
]

{ #category : 'accessing' }
CFPhysicsOverlay >> host [ ^ host ]

{ #category : 'accessing' }
CFPhysicsOverlay >> host: anElement [ host := anElement ]

{ #category : 'accessing' }
CFPhysicsOverlay >> world [ ^ world ]

{ #category : 'accessing' }
CFPhysicsOverlay >> world: aWorld [ world := aWorld ]

{ #category : 'accessing' }
CFPhysicsOverlay >> root [ ^ root ]

{ #category : 'accessing' }
CFPhysicsOverlay >> bodyElements [ ^ bodyElements values asArray ]

{ #category : 'initialization' }
CFPhysicsOverlay >> initializeOverlay [
	bodyElements := IdentityDictionary new.
	root := BlOverlayElement on: host.
	root
		id: #cfPhysicsOverlay;
		clipChildren: false;
		preventMeAndChildrenMouseEvents.
	context := CFPhysicsOverlayContext host: host world: world overlay: self
]

{ #category : 'testing' }
CFPhysicsOverlay >> isInstalled [
	^ root hasParent
]

{ #category : 'installing' }
CFPhysicsOverlay >> install [
	| container |
	self isInstalled ifTrue: [ ^ self ].
	container := host parent.
	container ifNil: [ self error: 'The physics host must be in a Bloc presentation before its overlay can be shown' ].
	container addChild: root.
	self refresh.
	^ self
]

{ #category : 'updating' }
CFPhysicsOverlay >> refresh [
	| bodies live |
	world synchroniseMembership.
	bodies := world bodyStatesInOrder.
	live := IdentitySet new.
	live addAll: bodies.
	(bodyElements keys reject: [ :each | live includes: each ]) do: [ :body |
		| anElement |
		anElement := bodyElements removeKey: body.
		anElement release.
		anElement removeFromParent ].
	bodies do: [ :body |
		| anElement |
		anElement := bodyElements
			at: body
			ifAbsentPut: [
				| created |
				created := body physicsOverlayElementIn: context.
				root addChild: created.
				created ].
		anElement refresh ].
	^ self
]

{ #category : 'controlling' }
CFPhysicsOverlay >> release [
	bodyElements valuesDo: [ :each | each release ].
	bodyElements removeAll.
	root detach.
	root hasParent ifTrue: [ root removeFromParent ]
]
