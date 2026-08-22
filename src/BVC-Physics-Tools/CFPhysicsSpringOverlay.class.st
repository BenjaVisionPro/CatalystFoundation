"
I manage the retained spring diagnostics for one Physics overlay. My responsibility is to reconcile the world's springs with their visual representations and resolve spring selections from those visuals.
"
Class {
	#name : 'CFPhysicsSpringOverlay',
	#superclass : 'Object',
	#instVars : [
		'root',
		'world',
		'context',
		'visualsBySpring'
	],
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

{ #category : 'controlling' }
CFPhysicsSpringOverlay >> clear [
	visualsBySpring valuesDo: #release.
	visualsBySpring removeAll.
	^ self
]

{ #category : 'accessing' }
CFPhysicsSpringOverlay >> context: aContext [ context := aContext
]

{ #category : 'initialization' }
CFPhysicsSpringOverlay >> initializeOverlay [ visualsBySpring := IdentityDictionary new
]

{ #category : 'controlling' }
CFPhysicsSpringOverlay >> release [ ^ self clear
]

{ #category : 'accessing' }
CFPhysicsSpringOverlay >> root: anElement [ root := anElement
]

{ #category : 'testing' }
CFPhysicsSpringOverlay >> springForEventTarget: anElement [
	| visual |
	visual := self visualForEventTarget: anElement.
	^ visual ifNil: [ nil ] ifNotNil: [ visual spring ]
]

{ #category : 'updating' }
CFPhysicsSpringOverlay >> update [
	^ self updateFrom: world springs
]

{ #category : 'updating' }
CFPhysicsSpringOverlay >> updateFrom: springs [
	| live |
	live := IdentitySet new.
	live addAll: springs.
	(visualsBySpring keys reject: [ :each | live includes: each ]) do: [ :spring |
		(visualsBySpring removeKey: spring) release ].
	springs do: [ :spring |
		visualsBySpring at: spring ifAbsentPut: [
			(CFPhysicsSpringVisual diagnosticOn: spring context: context)
				addTo: root;
				yourself ] ].
	self updateGeometry.
	^ self
]

{ #category : 'updating' }
CFPhysicsSpringOverlay >> updateGeometry [
	visualsBySpring valuesDo: #update.
	^ self
]

{ #category : 'testing' }
CFPhysicsSpringOverlay >> visualForEventTarget: anElement [
	^ visualsBySpring values
		detect: [ :each | each includesEventTarget: anElement ]
		ifNone: [ nil ]
]

{ #category : 'accessing' }
CFPhysicsSpringOverlay >> visuals [ ^ visualsBySpring values asArray
]

{ #category : 'accessing' }
CFPhysicsSpringOverlay >> world: aWorld [ world := aWorld
]
