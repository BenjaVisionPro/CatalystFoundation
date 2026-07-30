Class {
	#name : 'CFPhysicsJointInspectorContent',
	#superclass : 'Object',
	#instVars : [ 'element', 'joint', 'valueElements' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsJointInspectorContent class >> newContent [
	^ self new
		initializeContent;
		yourself
]

{ #category : 'accessing' }
CFPhysicsJointInspectorContent >> element [ ^ element ]

{ #category : 'accessing' }
CFPhysicsJointInspectorContent >> joint [ ^ joint ]

{ #category : 'accessing' }
CFPhysicsJointInspectorContent >> valueElementAt: aKey [
	^ valueElements at: aKey
]

{ #category : 'accessing' }
CFPhysicsJointInspectorContent >> valueElements [ ^ valueElements ]

{ #category : 'initialization' }
CFPhysicsJointInspectorContent >> initializeContent [
	valueElements := Dictionary new.
	element := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 6;
		yourself.
	element addChild: (self newTitle: 'JOINT').
	element addChild: (self newGroup: 'State' fields: {
		#jointType -> 'Type'.
		#active -> 'Active'.
		#sequence -> 'Sequence'.
		#collideConnected -> 'Collide connected' }).
	element addChild: (self newGroup: 'Connection' fields: {
		#bodyA -> 'First body'.
		#bodyB -> 'Second body' }).
	element addChild: (self newGroup: 'Anchors' fields: {
		#anchorA -> 'First anchor'.
		#anchorB -> 'Second anchor' })
]

{ #category : 'private - building' }
CFPhysicsJointInspectorContent >> newTitle: aString [
	^ BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.65));
		text: aString;
		yourself
]

{ #category : 'private - building' }
CFPhysicsJointInspectorContent >> newGroup: aName fields: associations [
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
CFPhysicsJointInspectorContent >> newRowFor: aKey label: aString [
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

{ #category : 'building' }
CFPhysicsJointInspectorContent >> addGroup: aName fields: associations [
	element addChild: (self newGroup: aName fields: associations).
	^ self
]

{ #category : 'updating' }
CFPhysicsJointInspectorContent >> text: aString at: aKey [
	(self valueElementAt: aKey) text: aString.
	^ self
]

{ #category : 'updating' }
CFPhysicsJointInspectorContent >> diagnosticNumber: aNumber at: aKey [
	^ self text: (self formatDiagnosticNumber: aNumber) at: aKey
]

{ #category : 'updating' }
CFPhysicsJointInspectorContent >> diagnosticPoint: aPoint at: aKey [
	^ self text: (self formatPoint: aPoint) at: aKey
]

{ #category : 'inspecting' }
CFPhysicsJointInspectorContent >> inspect: aJoint [
	joint := aJoint.
	joint addPhysicsOverlayInspectorGroupsTo: self.
	self refresh.
	^ self
]

{ #category : 'clearing' }
CFPhysicsJointInspectorContent >> clear [
	joint := nil.
	valueElements valuesDo: [ :each | each text: '' ].
	^ self
]

{ #category : 'private - formatting' }
CFPhysicsJointInspectorContent >> formatDiagnosticNumber: aNumber [
	^ aNumber asFloat printShowingDecimalPlaces: 4
]

{ #category : 'private - formatting' }
CFPhysicsJointInspectorContent >> formatPoint: aPoint [
	^ (self formatDiagnosticNumber: aPoint x), ' @ ',
		(self formatDiagnosticNumber: aPoint y)
]

{ #category : 'private - formatting' }
CFPhysicsJointInspectorContent >> labelForBody: aBody [
	aBody ifNil: [ ^ 'World anchor' ].
	^ aBody element gtDisplayString
]

{ #category : 'private - formatting' }
CFPhysicsJointInspectorContent >> jointTypeName [
	| name |
	name := joint class name.
	(name beginsWith: 'CFPhysics') ifTrue: [ name := name allButFirst: 9 ].
	(name endsWith: 'Joint') ifTrue: [ name := name allButLast: 5 ].
	^ name
]

{ #category : 'updating' }
CFPhysicsJointInspectorContent >> refresh [
	| points |
	joint ifNil: [ ^ self ].
	points := joint endpointPair worldPoints.
	(self valueElementAt: #jointType) text: self jointTypeName.
	(self valueElementAt: #active) text: joint isActive printString.
	(self valueElementAt: #sequence) text: joint sequence printString.
	(self valueElementAt: #collideConnected) text: joint collideConnected printString.
	(self valueElementAt: #bodyA) text: (self labelForBody: joint bodyA).
	(self valueElementAt: #bodyB) text: (self labelForBody: joint bodyB).
	(self valueElementAt: #anchorA) text: (self formatPoint: points first).
	(self valueElementAt: #anchorB) text: (self formatPoint: points second).
	joint refreshPhysicsOverlayInspector: self.
	^ self
]
