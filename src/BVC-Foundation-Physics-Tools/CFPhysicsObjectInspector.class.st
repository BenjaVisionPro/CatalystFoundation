Class {
	#name : 'CFPhysicsObjectInspector',
	#superclass : 'Object',
	#instVars : [
		'host',
		'root',
		'panel',
		'content',
		'selectedPhysics',
		'released',
		'visibilityMotion'
	],
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
CFPhysicsObjectInspector >> host [ ^ host ]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> host: anElement [ host := anElement ]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> panel [ ^ panel ]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> root [ ^ root ]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> content [ ^ content ]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> selectedPhysics [ ^ selectedPhysics ]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> valueElementAt: aKey [
	^ content valueElementAt: aKey
]

{ #category : 'initialization' }
CFPhysicsObjectInspector >> initializeInspector [
	released := false.
	root := BlOverlayElement on: host.
	root
		id: #cfPhysicsObjectInspector;
		layout: BlFrameLayout new;
		zIndex: (host elevation relatedTo: 0) + 2;
		clipChildren: false;
		preventMouseEvents.
	panel := self newPanel.
	content := CFPhysicsBodyInspectorContent newContent.
	panel addChild: content element.
	root addChild: panel.
	self clearWithoutMotion
]

{ #category : 'private - building' }
CFPhysicsObjectInspector >> newPanel [
	^ BrVerticalPane new
		id: #cfPhysicsObjectInspectorPanel;
		hExact: 300;
		vFitContent;
		padding: (BlInsets all: 8);
		background: (Color black alpha: 0.1);
		border: (BlBorder paint: (Color black alpha: 0.12) width: 1);
		effect: (BlBlurBelowEffect radius: 14);
		geometry: (BlRoundedRectangleGeometry cornerRadii: (BlCornerRadii radius: 8));
		constraintsDo: [ :c |
			c frame horizontal alignLeft.
			c frame vertical alignCenter ];
		margin: (BlInsets all: 10);
		yourself
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
	released ifTrue: [ ^ self ].
	selectedPhysics := aPhysics.
	content inspect: aPhysics.
	self showPanel.
	^ self
]

{ #category : 'clearing' }
CFPhysicsObjectInspector >> clear [
	selectedPhysics := nil.
	content clear.
	self hidePanel.
	^ self
]

{ #category : 'private - visibility' }
CFPhysicsObjectInspector >> clearWithoutMotion [
	selectedPhysics := nil.
	content clear.
	visibilityMotion ifNotNil: [
		visibilityMotion cancelPreservingCurrentPresentation.
		visibilityMotion := nil ].
	panel
		opacity: 0.0;
		visibility: BlVisibility gone.
	^ self
]

{ #category : 'private - visibility' }
CFPhysicsObjectInspector >> showPanel [
	panel visibility: BlVisibility visible.
	panel isAttachedToSceneGraph ifFalse: [
		panel opacity: 1.0.
		^ self ].
	self animateOpacityTo: 1.0 duration: 180 milliSeconds.
	^ self
]

{ #category : 'private - visibility' }
CFPhysicsObjectInspector >> hidePanel [
	panel visibility == BlVisibility gone ifTrue: [ ^ self ].
	panel isAttachedToSceneGraph ifFalse: [ ^ self clearWithoutMotion ].
	panel opacity = 0.0 ifTrue: [
		panel visibility: BlVisibility gone.
		^ self ].
	self animateOpacityTo: 0.0 duration: 140 milliSeconds.
	^ self
]

{ #category : 'private - visibility' }
CFPhysicsObjectInspector >> animateOpacityTo: anOpacity duration: aDuration [
	| aMotion |
	aMotion := panel space cfMotionCoordinator
		retarget: (CFMotionPropertyTrack
			on: panel
			property: CFMotionOpacityProperty uniqueInstance
			target: anOpacity)
		duration: aDuration
		easing: (BlDecelerateInterpolator factor: 1.4).
	visibilityMotion := aMotion.
	aMotion onTerminalDo: [ :completedMotion |
		visibilityMotion == completedMotion ifTrue: [ visibilityMotion := nil ].
		(selectedPhysics isNil
			and: [ completedMotion isCompleted
			and: [ panel opacity = 0.0 ] ]) ifTrue: [
			panel visibility: BlVisibility gone ] ].
	^ aMotion
]

{ #category : 'testing' }
CFPhysicsObjectInspector >> includesEventTarget: anElement [
	| current |
	current := anElement.
	[ current notNil ] whileTrue: [
		current == panel ifTrue: [ ^ true ].
		current := current parent ].
	^ false
]

{ #category : 'updating' }
CFPhysicsObjectInspector >> refresh [
	selectedPhysics ifNil: [ ^ self ].
	content refresh.
	^ self
]

{ #category : 'controlling' }
CFPhysicsObjectInspector >> release [
	released ifTrue: [ ^ self ].
	released := true.
	visibilityMotion ifNotNil: #cancel.
	self clearWithoutMotion.
	root detach.
	root hasParent ifTrue: [ root removeFromParent ].
	^ self
]
