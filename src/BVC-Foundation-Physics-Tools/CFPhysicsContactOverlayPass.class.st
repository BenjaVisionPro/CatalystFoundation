Class {
	#name : 'CFPhysicsContactOverlayPass',
	#superclass : 'Object',
	#instVars : [ 'root', 'context', 'elements' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsContactOverlayPass class >> in: anOverlayRoot context: aContext [
	^ self new
		root: anOverlayRoot;
		context: aContext;
		initializePass;
		yourself
]

{ #category : 'accessing' }
CFPhysicsContactOverlayPass >> elements [
	^ elements asArray
]

{ #category : 'initialization' }
CFPhysicsContactOverlayPass >> initializePass [
	elements := OrderedCollection new
]

{ #category : 'private - initialization' }
CFPhysicsContactOverlayPass >> root: anElement [
	root := anElement
]

{ #category : 'private - initialization' }
CFPhysicsContactOverlayPass >> context: aContext [
	context := aContext
]

{ #category : 'updating' }
CFPhysicsContactOverlayPass >> refresh [
	self removeElements.
	context world activeContacts do: [ :contact |
		contact isTouching ifTrue: [ self addContact: contact ] ].
	^ self
]

{ #category : 'private - updating' }
CFPhysicsContactOverlayPass >> addContact: aContact [
	| manifold displayedPoints |
	manifold := aContact manifold.
	(manifold isNil or: [ manifold normal isNil ]) ifTrue: [ ^ self ].
	displayedPoints := manifold contactPoints collect: [ :point |
		context overlayPointFromWorld: point position ].
	displayedPoints size = 2 ifTrue: [
		self
			addLineFrom: displayedPoints first
			to: displayedPoints second
			paint: (Color magenta alpha: 0.55)
			width: 1 ].
	manifold contactPoints with: displayedPoints do: [ :point :displayedPoint |
		self addContactPointAt: displayedPoint.
		self
			addLineFrom: displayedPoint
			to: (context overlayPointFromWorld: point position + (manifold normal * 24.0))
			paint: (Color green alpha: 0.8)
			width: 1.
		point separation isZero ifFalse: [
			self
				addLineFrom: displayedPoint
				to: (context overlayPointFromWorld: point position + (manifold normal * point separation))
				paint: ((point separation < 0
					ifTrue: [ Color red ]
					ifFalse: [ Color yellow ]) alpha: 0.8)
				width: 2 ] ]
]

{ #category : 'private - updating' }
CFPhysicsContactOverlayPass >> addContactPointAt: aPoint [
	| marker |
	marker := BlElement new
		geometry: BlCircleGeometry new;
		size: 6 @ 6;
		background: (Color magenta alpha: 0.9);
		constraintsDo: [ :c | c ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		relocate: aPoint - (3 @ 3);
		yourself.
	self addElement: marker
]

{ #category : 'private - updating' }
CFPhysicsContactOverlayPass >> addLineFrom: firstPoint to: secondPoint paint: aPaint width: aNumber [
	| line |
	line := BlLineElement new
		fromAnchor: (BlAbsolutePositionAnchor position: firstPoint);
		toAnchor: (BlAbsolutePositionAnchor position: secondPoint);
		border: (BlBorder paint: aPaint width: aNumber);
		constraintsDo: [ :c | c ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		yourself.
	self addElement: line
]

{ #category : 'private - updating' }
CFPhysicsContactOverlayPass >> addElement: anElement [
	elements add: anElement.
	root addChild: anElement
]

{ #category : 'private - updating' }
CFPhysicsContactOverlayPass >> removeElements [
	elements do: [ :each | each hasParent ifTrue: [ each removeFromParent ] ].
	elements removeAll
]

{ #category : 'controlling' }
CFPhysicsContactOverlayPass >> release [
	self removeElements
]
