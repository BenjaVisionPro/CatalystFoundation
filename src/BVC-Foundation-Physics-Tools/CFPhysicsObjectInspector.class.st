Class {
	#name : 'CFPhysicsObjectInspector',
	#superclass : 'Object',
	#instVars : [
		'host',
		'root',
		'panel',
		'contentContainer',
		'content',
		'selectedObject',
		'released',
		'visibilityMotion',
		'contentTransitionMotion',
		'outgoingContentElement'
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
CFPhysicsObjectInspector >> contentContainer [ ^ contentContainer ]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> contentTransitionMotion [ ^ contentTransitionMotion ]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> selectedObject [ ^ selectedObject ]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> selectedPhysics [ ^ selectedObject ]

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
	contentContainer := self newContentContainer.
	content := nil.
	panel addChild: contentContainer.
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

{ #category : 'private - building' }
CFPhysicsObjectInspector >> newContentContainer [
	^ BlElement new
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
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
	aPhysics inspectInPhysicsOverlay: self.
	^ self
]

{ #category : 'inspecting' }
CFPhysicsObjectInspector >> inspect: anObject usingContent: aContent [
	| shouldAnimate sourceExtent outgoingElement targetExtent |
	released ifTrue: [ ^ self ].
	shouldAnimate := selectedObject notNil
		and: [ content notNil and: [ panel isAttachedToSceneGraph ] ].
	sourceExtent := shouldAnimate ifTrue: [ panel extent ].
	self cancelContentTransition.
	outgoingElement := content ifNotNil: [ content element ].
	selectedObject := anObject.
	content := aContent.
	content inspect: anObject.
	shouldAnimate
		ifTrue: [
			targetExtent := self measurePanelExtentFor: content element.
			self prepareOutgoingContent: outgoingElement.
			content element opacity: 0.0.
			self addContentElement: content element ]
		ifFalse: [
			outgoingElement ifNotNil: [ outgoingElement removeFromParent ].
			self addContentElement: content element ].
	shouldAnimate ifTrue: [
		self
			animateContentTransitionFrom: sourceExtent
			to: targetExtent
			outgoing: outgoingElement
			incoming: content element ].
	self showPanel.
	^ self
]

{ #category : 'clearing' }
CFPhysicsObjectInspector >> clear [
	selectedObject := nil.
	self cancelContentTransition.
	content ifNotNil: [ content clear ].
	panel constraintsDo: [ :c | c vertical fitContent ].
	self hidePanel.
	^ self
]

{ #category : 'private - visibility' }
CFPhysicsObjectInspector >> clearWithoutMotion [
	selectedObject := nil.
	content ifNotNil: [ content clear ].
	self cancelContentTransition.
	panel constraintsDo: [ :c | c vertical fitContent ].
	visibilityMotion ifNotNil: [
		visibilityMotion cancelPreservingCurrentPresentation.
		visibilityMotion := nil ].
	panel
		opacity: 0.0;
		visibility: BlVisibility gone.
	^ self
]

{ #category : 'private - content transition' }
CFPhysicsObjectInspector >> addContentElement: anElement [
	anElement constraintsDo: [ :c |
		c frame horizontal alignLeft.
		c frame vertical alignTop ].
	contentContainer addChild: anElement.
	^ self
]

{ #category : 'private - content transition' }
CFPhysicsObjectInspector >> prepareOutgoingContent: anElement [
	anElement constraintsDo: [ :c |
		c ignoreByLayout.
		c ignored horizontal alignLeft.
		c ignored vertical alignTop ].
	outgoingContentElement := anElement.
	^ self
]

{ #category : 'private - content transition' }
CFPhysicsObjectInspector >> measurePanelExtentFor: anElement [
	| measurementPanel targetExtent |
	measurementPanel := self newPanel.
	measurementPanel
		visibility: BlVisibility hidden;
		constraintsDo: [ :c |
			c ignoreByLayout.
			c ignored horizontal alignLeft.
			c ignored vertical alignTop ].
	measurementPanel addChild: anElement.
	root addChild: measurementPanel.
	root space pulse.
	targetExtent := measurementPanel extent.
	anElement removeFromParent.
	measurementPanel removeFromParent.
	^ targetExtent
]

{ #category : 'private - content transition' }
CFPhysicsObjectInspector >> cancelContentTransition [
	| aMotion |
	aMotion := contentTransitionMotion.
	contentTransitionMotion := nil.
	aMotion ifNotNil: [ aMotion cancelPreservingCurrentPresentation ].
	outgoingContentElement ifNotNil: [ :anElement |
		anElement removeFromParent.
		outgoingContentElement := nil ].
	content ifNotNil: [ content element opacity: 1.0 ].
	^ self
]

{ #category : 'private - content transition' }
CFPhysicsObjectInspector >> animateContentTransitionFrom: aSourceExtent to: aTargetExtent outgoing: anOutgoingElement incoming: anIncomingElement [
	| tracks aMotion |
	tracks := {
		CFMotionPropertyTrack
			on: anOutgoingElement
			property: CFMotionOpacityProperty uniqueInstance
			target: 0.0.
		CFMotionPropertyTrack
			on: anIncomingElement
			property: CFMotionOpacityProperty uniqueInstance
			target: 1.0.
		(CFMotionExtentTrack
			on: panel
			from: aSourceExtent
			to: aTargetExtent)
			fitContentAtDestination }.
	aMotion := CFMotion
		coordinator: panel space cfMotionCoordinator
		tracks: tracks.
	contentTransitionMotion := aMotion.
	aMotion
		duration: 180 milliSeconds;
		easing: (BlDecelerateInterpolator factor: 1.4);
		onTerminalDo: [ :aCompletedMotion |
			contentTransitionMotion == aCompletedMotion ifTrue: [
				outgoingContentElement ifNotNil: [ :anElement |
					anElement removeFromParent ].
				outgoingContentElement := nil.
				contentTransitionMotion := nil ] ];
		start.
	^ aMotion
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
		(selectedObject isNil
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
	selectedObject ifNil: [ ^ self ].
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
