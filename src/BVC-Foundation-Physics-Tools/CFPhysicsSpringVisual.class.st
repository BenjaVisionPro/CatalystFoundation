Class {
	#name : 'CFPhysicsSpringVisual',
	#superclass : 'BlElement',
	#instVars : [ 'spring', 'presentationRole' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsSpringVisual class >> diagnosticOn: aSpring [
	^ self new
		spring: aSpring;
		presentationRole: #diagnostic;
		initializeVisual;
		yourself
]

{ #category : 'instance creation' }
CFPhysicsSpringVisual class >> selectionOn: aSpring [
	^ self new
		spring: aSpring;
		presentationRole: #selection;
		initializeVisual;
		yourself
]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> spring [ ^ spring ]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> spring: aSpring [ spring := aSpring ]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> presentationRole [ ^ presentationRole ]

{ #category : 'accessing' }
CFPhysicsSpringVisual >> presentationRole: aSymbol [ presentationRole := aSymbol ]

{ #category : 'testing' }
CFPhysicsSpringVisual >> isDiagnostic [ ^ presentationRole = #diagnostic ]

{ #category : 'testing' }
CFPhysicsSpringVisual >> isSelection [ ^ presentationRole = #selection ]

{ #category : 'initialization' }
CFPhysicsSpringVisual >> initializeVisual [
	self
		constraintsDo: [ :c | c ignoreByLayout ];
		background: Color transparent;
		preventMeAndChildrenMouseEvents.
	self isSelection ifTrue: [ self zIndex: 2 ]
]

{ #category : 'installing' }
CFPhysicsSpringVisual >> addTo: aParentElement [
	aParentElement addChild: self.
	^ self
]

{ #category : 'removing' }
CFPhysicsSpringVisual >> remove [
	self hasParent ifTrue: [ self removeFromParent ].
	^ self
]

{ #category : 'controlling' }
CFPhysicsSpringVisual >> release [ ^ self remove ]
