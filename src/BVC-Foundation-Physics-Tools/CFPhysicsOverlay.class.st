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
	(container notNil and: [ host isAttachedToSceneGraph ])
		ifFalse: [ self error: 'The physics host must be attached to a Bloc space before its overlay can be shown' ].
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

{ #category : 'actions' }
CFPhysicsOverlay class >> hostFor: anObject [
	^ (anObject respondsTo: #physicsOverlayHost)
		ifTrue: [ anObject physicsOverlayHost ]
		ifFalse: [ nil ]
]

{ #category : 'testing' }
CFPhysicsOverlay class >> hasWorldFor: anObject [
	| aHost physics |
	aHost := self hostFor: anObject.
	aHost ifNil: [ ^ false ].
	physics := aHost existingPhysics.
	^ physics notNil and: [ physics isWorld ]
]

{ #category : 'actions' }
CFPhysicsOverlay class >> toggleFor: anObject [
	| aHost |
	aHost := self hostFor: anObject.
	(self hasWorldFor: anObject)
		ifFalse: [ ^ nil ].
	^ aHost togglePhysicsOverlay
]

{ #category : 'actions' }
CFPhysicsOverlay class >> gtToggleActionFor: anObject action: anAction [
	(self hasWorldFor: anObject)
		ifFalse: [ ^ anAction noAction ].
	^ anAction button
		icon: BrGlamorousVectorIcons inspect;
		tooltip: 'Toggle physics overlay';
		action: [ self toggleFor: anObject ]
]
