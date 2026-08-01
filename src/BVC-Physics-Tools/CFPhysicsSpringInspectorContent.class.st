"I present the live diagnostic state of one Physics spring. My responsibility is to keep the overlay inspector fields synchronised with the selected spring and its endpoints."
Class {
	#name : 'CFPhysicsSpringInspectorContent',
	#superclass : 'Object',
	#instVars : [ 'element', 'spring', 'valueElements' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsSpringInspectorContent class >> newContent [
	^ self new
		initializeContent;
		yourself
]

{ #category : 'accessing' }
CFPhysicsSpringInspectorContent >> element [ ^ element ]

{ #category : 'accessing' }
CFPhysicsSpringInspectorContent >> spring [ ^ spring ]

{ #category : 'accessing' }
CFPhysicsSpringInspectorContent >> valueElementAt: aKey [
	^ valueElements at: aKey
]

{ #category : 'initialization' }
CFPhysicsSpringInspectorContent >> initializeContent [
	valueElements := Dictionary new.
	element := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 6;
		yourself.
	element addChild: (self newTitle: 'SPRING').
	element addChild: (self newGroup: 'Connection' fields: {
		#bodyA -> 'First body'.
		#bodyB -> 'Second body' }).
	element addChild: (self newGroup: 'Geometry' fields: {
		#length -> 'Length'.
		#currentLength -> 'Current length'.
		#extension -> 'Extension' }).
	element addChild: (self newGroup: 'Response' fields: {
		#hertz -> 'Hertz'.
		#dampingRatio -> 'Damping ratio'.
		#springEnabled -> 'Spring enabled'.
		#active -> 'Active' })
]

{ #category : 'private - building' }
CFPhysicsSpringInspectorContent >> newTitle: aString [
	^ BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.65));
		text: aString;
		yourself
]

{ #category : 'private - building' }
CFPhysicsSpringInspectorContent >> newGroup: aName fields: associations [
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
CFPhysicsSpringInspectorContent >> newRowFor: aKey label: aString [
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
CFPhysicsSpringInspectorContent >> inspect: aSpring [
	spring := aSpring.
	self refresh.
	^ self
]

{ #category : 'clearing' }
CFPhysicsSpringInspectorContent >> clear [
	spring := nil.
	valueElements valuesDo: [ :each | each text: '' ].
	^ self
]

{ #category : 'private - formatting' }
CFPhysicsSpringInspectorContent >> formatDiagnosticNumber: aNumber [
	^ aNumber asFloat printShowingDecimalPlaces: 4
]

{ #category : 'private - formatting' }
CFPhysicsSpringInspectorContent >> labelForBody: aBody [
	aBody ifNil: [ ^ 'World anchor' ].
	^ aBody element gtDisplayString
]

{ #category : 'updating' }
CFPhysicsSpringInspectorContent >> refresh [
	| points currentLength length |
	spring ifNil: [ ^ self ].
	points := spring endpointPair worldPoints.
	currentLength := (points second - points first) r.
	length := spring length asFloat.
	(self valueElementAt: #bodyA) text: (self labelForBody: spring bodyA).
	(self valueElementAt: #bodyB) text: (self labelForBody: spring bodyB).
	(self valueElementAt: #length) text: (self formatDiagnosticNumber: length).
	(self valueElementAt: #currentLength) text: (self formatDiagnosticNumber: currentLength).
	(self valueElementAt: #extension) text: (self formatDiagnosticNumber: currentLength - length).
	(self valueElementAt: #hertz) text: (self formatDiagnosticNumber: spring hertz).
	(self valueElementAt: #dampingRatio) text: (self formatDiagnosticNumber: spring dampingRatio).
	(self valueElementAt: #springEnabled) text: spring springEnabled printString.
	(self valueElementAt: #active) text: spring isActive printString.
	^ self
]
