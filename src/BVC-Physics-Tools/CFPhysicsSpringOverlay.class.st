Class {
	#name : 'CFPhysicsSpringOverlay',
	#superclass : 'Object',
	#instVars : [ 'root', 'world', 'context', 'visualsBySpring' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsSpringOverlay class >> in: aRoot world: aWorld context: aContext [
	^ self new
		root: aRoot;
		world: aWorld;
		context: aContext;
		initializeOverlay;
		yourself
]

{ #category : 'accessing' }
CFPhysicsSpringOverlay >> root: anElement [ root := anElement ]

{ #category : 'accessing' }
CFPhysicsSpringOverlay >> world: aWorld [ world := aWorld ]

{ #category : 'accessing' }
CFPhysicsSpringOverlay >> context: aContext [ context := aContext ]

{ #category : 'accessing' }
CFPhysicsSpringOverlay >> visuals [ ^ visualsBySpring values asArray ]

{ #category : 'testing' }
CFPhysicsSpringOverlay >> visualForEventTarget: anElement [
	^ visualsBySpring values
		detect: [ :each | each includesEventTarget: anElement ]
		ifNone: [ nil ]
]

{ #category : 'testing' }
CFPhysicsSpringOverlay >> springForEventTarget: anElement [
	| visual |
	visual := self visualForEventTarget: anElement.
	^ visual ifNil: [ nil ] ifNotNil: [ visual spring ]
]

{ #category : 'initialization' }
CFPhysicsSpringOverlay >> initializeOverlay [ visualsBySpring := IdentityDictionary new ]

{ #category : 'updating' }
CFPhysicsSpringOverlay >> update [
	| springs live |
	springs := world springConstraints.
	live := IdentitySet new.
	live addAll: springs.
	(visualsBySpring keys reject: [ :each | live includes: each ]) do: [ :spring |
		(visualsBySpring removeKey: spring) release ].
	springs do: [ :spring |
		| visual |
		visual := visualsBySpring at: spring ifAbsentPut: [
			(CFPhysicsSpringVisual diagnosticOn: spring context: context)
				addTo: root;
				yourself ].
		visual update ].
	^ self
]

{ #category : 'controlling' }
CFPhysicsSpringOverlay >> clear [
	visualsBySpring valuesDo: #release.
	visualsBySpring removeAll.
	^ self
]

{ #category : 'controlling' }
CFPhysicsSpringOverlay >> release [ ^ self clear ]
