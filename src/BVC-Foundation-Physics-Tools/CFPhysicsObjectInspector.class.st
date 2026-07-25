Class {
	#name : 'CFPhysicsObjectInspector',
	#superclass : 'Object',
	#instVars : [ 'host', 'root', 'selectedPhysics', 'form', 'memento', 'formGeneration', 'released' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsObjectInspector class >> on: aHostElement [
	^ self new
		host: aHostElement;
		initializeInspector;
		yourself
]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> form [
	^ form
]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> formGeneration [
	^ formGeneration
]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> host [
	^ host
]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> host: anElement [
	host := anElement
]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> memento [
	^ memento
]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> root [
	^ root
]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> selectedPhysics [
	^ selectedPhysics
]

{ #category : 'initialization' }
CFPhysicsObjectInspector >> initializeInspector [
	formGeneration := 0.
	released := false.
	root := BlOverlayElement on: host.
	root
		id: #cfPhysicsObjectInspector;
		zIndex: (host elevation relatedTo: 0) + 2;
		clipChildren: false
]

{ #category : 'testing' }
CFPhysicsObjectInspector >> isInstalled [
	^ root hasParent
]

{ #category : 'installing' }
CFPhysicsObjectInspector >> install [
	| container |
	self isInstalled ifTrue: [ ^ self ].
	container := host parent.
	(container notNil and: [ host isAttachedToSceneGraph ])
		ifFalse: [ self error: 'The Physics host must be attached to a Bloc space before its object inspector can be shown' ].
	container addChild: root.
	^ self
]

{ #category : 'inspecting' }
CFPhysicsObjectInspector >> inspect: aPhysics [
	| generation viewModel |
	selectedPhysics == aPhysics ifTrue: [ ^ self ].
	self clearForm.
	selectedPhysics := aPhysics.
	formGeneration := formGeneration + 1.
	generation := formGeneration.
	viewModel := aPhysics asGtMagritteViewModel.
	viewModel
		ignoreImplicitActions;
		onElementCreated: [ :aFrame |
			self
				formCreated: aFrame
				for: aPhysics
				generation: generation ].
	form := viewModel asElement.
	form
		constraintsDo: [ :c |
			c frame horizontal alignRight.
			c frame vertical alignTop ];
		margin: (BlInsets all: 10).
	root addChild: form.
	^ self
]

{ #category : 'private' }
CFPhysicsObjectInspector >> formCreated: aFrame for: aPhysics generation: aGeneration [
	(released
		or: [ formGeneration ~= aGeneration
		or: [ selectedPhysics ~~ aPhysics
		or: [ form ~~ aFrame ] ] ]) ifTrue: [ ^ self ].
	memento := aFrame userData
		at: GtMagritteViewModel gtMementoSymbol
		ifAbsent: [ nil ].
	^ self
]

{ #category : 'clearing' }
CFPhysicsObjectInspector >> clear [
	formGeneration := formGeneration + 1.
	selectedPhysics := nil.
	self clearForm.
	^ self
]

{ #category : 'private' }
CFPhysicsObjectInspector >> clearForm [
	memento := nil.
	form ifNotNil: [
		form removeFromParent.
		form := nil ].
	^ self
]

{ #category : 'testing' }
CFPhysicsObjectInspector >> includesEventTarget: anElement [
	| current |
	current := anElement.
	[ current notNil ] whileTrue: [
		current == root ifTrue: [ ^ true ].
		current := current parent ].
	^ false
]

{ #category : 'controlling' }
CFPhysicsObjectInspector >> release [
	released ifTrue: [ ^ self ].
	released := true.
	self clear.
	root detach.
	root hasParent ifTrue: [ root removeFromParent ].
	^ self
]
