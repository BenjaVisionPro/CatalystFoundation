Class {
	#name : 'CFPhysicsObjectInspector',
	#superclass : 'Object',
	#instVars : [
		'host',
		'root',
		'panel',
		'selectedPhysics',
		'valueElements',
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
CFPhysicsObjectInspector >> host [
	^ host
]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> host: anElement [
	host := anElement
]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> panel [
	^ panel
]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> root [
	^ root
]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> selectedPhysics [
	^ selectedPhysics
]

{ #category : 'accessing' }
CFPhysicsObjectInspector >> valueElementAt: aKey [
	^ valueElements at: aKey
]

{ #category : 'initialization' }
CFPhysicsObjectInspector >> initializeInspector [
	released := false.
	valueElements := Dictionary new.
	root := BlOverlayElement on: host.
	root
		id: #cfPhysicsObjectInspector;
		layout: BlFrameLayout new;
		zIndex: (host elevation relatedTo: 0) + 2;
		clipChildren: false;
		preventMouseEvents.
	panel := self newPanel.
	root addChild: panel.
	self clearWithoutMotion
]

{ #category : 'private - building' }
CFPhysicsObjectInspector >> newPanel [
	| anElement |
	anElement := BrVerticalPane new
		id: #cfPhysicsObjectInspectorPanel;
		hExact: 300;
		vFitContent;
		cellSpacing: 6;
		padding: (BlInsets all: 8);
		background: (Color black alpha: 0.1);
		border: (BlBorder paint: (Color black alpha: 0.12) width: 1);
		effect: (BlBlurBelowEffect radius: 14);
		geometry: (BlRoundedRectangleGeometry cornerRadii: (BlCornerRadii radius: 8));
		constraintsDo: [ :c |
			c frame horizontal alignLeft.
			c frame vertical alignCenter ];
		margin: (BlInsets all: 10);
		yourself.
	anElement addChild: (self newTitle: 'PHYSICS OBJECT').
	anElement addChild: (self
		newVectorRowWithIcon: #arrows
		xKey: #positionX
		yKey: #positionY
		rotationKey: #rotation).
	anElement addChild: (self
		newVectorRowWithIcon: #tachometer
		xKey: #velocityX
		yKey: #velocityY
		rotationKey: #angularVelocity).
	anElement addChild: (self newGroup: 'State' fields: {
		#bodyType -> 'Body type'.
		#awake -> 'Awake'.
		#sensor -> 'Sensor' }).
	anElement addChild: (self newGroup: 'Material' fields: {
		#density -> 'Density'.
		#friction -> 'Friction'.
		#restitution -> 'Restitution' }).
	^ anElement
]

{ #category : 'private - building' }
CFPhysicsObjectInspector >> newIconNamed: anIconName [
	^ (FontAwesomeIcons defaultStyle icon: anIconName)
		size: 14 @ 14;
		yourself
]

{ #category : 'private - building' }
CFPhysicsObjectInspector >> newVectorValueFor: aKey [
	| valueElement |
	valueElement := BrLabel new
		hExact: 68;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: Color black);
		text: '';
		yourself.
	valueElements at: aKey put: valueElement.
	^ valueElement
]

{ #category : 'private - building' }
CFPhysicsObjectInspector >> newVectorRowWithIcon: anIconName xKey: anXKey yKey: aYKey rotationKey: aRotationKey [
	^ BrHorizontalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 5;
		addChild: (self newIconNamed: anIconName);
		addChild: (self newVectorValueFor: anXKey);
		addChild: (BrLabel new
			fitContent;
			aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.48));
			text: '@';
			yourself);
		addChild: (self newVectorValueFor: aYKey);
		addChild: (self newIconNamed: #angleLeft);
		addChild: (self newVectorValueFor: aRotationKey);
		yourself
]

{ #category : 'private - building' }
CFPhysicsObjectInspector >> newTitle: aString [
	^ BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.65));
		text: aString;
		yourself
]

{ #category : 'private - building' }
CFPhysicsObjectInspector >> newGroup: aName fields: associations [
	| group |
	group := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 5;
		yourself.
	group addChild: (BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.38));
		text: aName asUppercase;
		yourself).
	associations do: [ :each |
		group addChild: (self newRowFor: each key label: each value) ].
	^ group
]

{ #category : 'private - building' }
CFPhysicsObjectInspector >> newRowFor: aKey label: aString [
	| row nameElement valueElement |
	nameElement := BrLabel new
		hExact: 112;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.48));
		text: aString;
		yourself.
	valueElement := BrLabel new
		hMatchParent;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: Color black);
		text: '';
		yourself.
	valueElements at: aKey put: valueElement.
	row := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 8;
		addChild: nameElement;
		addChild: valueElement;
		yourself.
	^ row
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
	self showPanel.
	self refresh.
	^ self
]

{ #category : 'clearing' }
CFPhysicsObjectInspector >> clear [
	selectedPhysics := nil.
	valueElements valuesDo: [ :each | each text: '' ].
	self hidePanel.
	^ self
]

{ #category : 'private - visibility' }
CFPhysicsObjectInspector >> clearWithoutMotion [
	selectedPhysics := nil.
	valueElements valuesDo: [ :each | each text: '' ].
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
	panel isAttachedToSceneGraph ifFalse: [
		^ self clearWithoutMotion ].
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

{ #category : 'private - formatting' }
CFPhysicsObjectInspector >> formatDiagnosticNumber: aNumber [
	^ aNumber asFloat printShowingDecimalPlaces: 4
]

{ #category : 'updating' }
CFPhysicsObjectInspector >> refresh [
	| physics position velocity |
	physics := selectedPhysics.
	physics ifNil: [ ^ self ].
	position := physics position.
	velocity := physics velocity.
	(self valueElementAt: #positionX) text: (self formatDiagnosticNumber: position x).
	(self valueElementAt: #positionY) text: (self formatDiagnosticNumber: position y).
	(self valueElementAt: #rotation) text: (self formatDiagnosticNumber: physics rotation).
	(self valueElementAt: #velocityX) text: (self formatDiagnosticNumber: velocity x).
	(self valueElementAt: #velocityY) text: (self formatDiagnosticNumber: velocity y).
	(self valueElementAt: #angularVelocity) text: (self formatDiagnosticNumber: physics angularVelocity).
	(self valueElementAt: #bodyType) text: physics bodyTypeName.
	(self valueElementAt: #awake) text: physics isAwake printString.
	(self valueElementAt: #sensor) text: physics isSensor printString.
	(self valueElementAt: #density) text: physics density printString.
	(self valueElementAt: #friction) text: physics friction printString.
	(self valueElementAt: #restitution) text: physics restitution printString.
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
