Class {
	#name : 'CFPhysicsBodyInspectorContent',
	#superclass : 'Object',
	#instVars : [
		'element',
		'physics',
		'valueElements'
	],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsBodyInspectorContent class >> newContent [
	^ self new
		initializeContent;
		yourself
]

{ #category : 'accessing' }
CFPhysicsBodyInspectorContent >> element [
	^ element
]

{ #category : 'accessing' }
CFPhysicsBodyInspectorContent >> physics [
	^ physics
]

{ #category : 'accessing' }
CFPhysicsBodyInspectorContent >> valueElementAt: aKey [
	^ valueElements at: aKey
]

{ #category : 'initialization' }
CFPhysicsBodyInspectorContent >> initializeContent [
	valueElements := Dictionary new.
	element := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 6;
		yourself.
	element addChild: (self newTitle: 'PHYSICS OBJECT').
	element addChild: (self
		newVectorRowWithIcon: #arrows
		xKey: #positionX
		yKey: #positionY
		rotationKey: #rotation).
	element addChild: (self
		newVectorRowWithIcon: #tachometer
		xKey: #velocityX
		yKey: #velocityY
		rotationKey: #angularVelocity).
	element addChild: (self newGroup: 'State' fields: {
		#bodyType -> 'Body type'.
		#awake -> 'Awake'.
		#sensor -> 'Sensor' }).
	element addChild: (self newGroup: 'Material' fields: {
		#density -> 'Density'.
		#friction -> 'Friction'.
		#restitution -> 'Restitution' })
]

{ #category : 'private - building' }
CFPhysicsBodyInspectorContent >> newIconNamed: anIconName [
	^ (FontAwesomeIcons defaultStyle icon: anIconName)
		size: 14 @ 14;
		yourself
]

{ #category : 'private - building' }
CFPhysicsBodyInspectorContent >> newVectorValueFor: aKey [
	| valueElement |
	valueElement := BrLabel new
		hExact: 68;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: Color black);
		text: '';
		yourself.
	valueElements at: aKey put: valueElement.
	^ valueElement
]

{ #category : 'private - building' }
CFPhysicsBodyInspectorContent >> newVectorRowWithIcon: anIconName xKey: anXKey yKey: aYKey rotationKey: aRotationKey [
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
CFPhysicsBodyInspectorContent >> newTitle: aString [
	^ BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.65));
		text: aString;
		yourself
]

{ #category : 'private - building' }
CFPhysicsBodyInspectorContent >> newGroup: aName fields: associations [
	| group |
	group := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 5;
		yourself.
	group addChild: (BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.38));
		text: aName asUppercase;
		yourself).
	associations do: [ :each |
		group addChild: (self newRowFor: each key label: each value) ].
	^ group
]

{ #category : 'private - building' }
CFPhysicsBodyInspectorContent >> newRowFor: aKey label: aString [
	| row nameElement valueElement |
	nameElement := BrLabel new
		hExact: 112;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.48));
		text: aString;
		yourself.
	valueElement := BrLabel new
		hMatchParent;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: Color black);
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

{ #category : 'inspecting' }
CFPhysicsBodyInspectorContent >> inspect: aPhysics [
	physics := aPhysics.
	self refresh.
	^ self
]

{ #category : 'clearing' }
CFPhysicsBodyInspectorContent >> clear [
	physics := nil.
	valueElements valuesDo: [ :each | each text: '' ].
	^ self
]

{ #category : 'private - formatting' }
CFPhysicsBodyInspectorContent >> formatDiagnosticNumber: aNumber [
	^ aNumber asFloat printShowingDecimalPlaces: 4
]

{ #category : 'updating' }
CFPhysicsBodyInspectorContent >> refresh [
	| position velocity |
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
