Class {
	#name : 'CFPhysicsSpringOverlay',
	#superclass : 'Object',
	#instVars : [ 'root', 'world', 'visualsBySpring' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsSpringOverlay class >> in: aRoot world: aWorld [
	^ self new
		root: aRoot;
		world: aWorld;
		initializeOverlay;
		yourself
]

{ #category : 'accessing' }
CFPhysicsSpringOverlay >> root: anElement [ root := anElement ]

{ #category : 'accessing' }
CFPhysicsSpringOverlay >> world: aWorld [ world := aWorld ]

{ #category : 'accessing' }
CFPhysicsSpringOverlay >> visuals [ ^ visualsBySpring values asArray ]

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
		visualsBySpring at: spring ifAbsentPut: [
			(CFPhysicsSpringVisual diagnosticOn: spring)
				addTo: root;
				yourself ] ].
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
