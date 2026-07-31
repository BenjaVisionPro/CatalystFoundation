Class {
	#name : 'CFPhysicsBodyOverlay',
	#superclass : 'Object',
	#instVars : [ 'root', 'world', 'context', 'visualsByBody' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsBodyOverlay class >> in: aRoot world: aWorld context: aContext [
	^ self new
		root: aRoot;
		world: aWorld;
		context: aContext;
		initializeOverlay;
		yourself
]

{ #category : 'accessing' }
CFPhysicsBodyOverlay >> root: anElement [ root := anElement ]

{ #category : 'accessing' }
CFPhysicsBodyOverlay >> world: aWorld [ world := aWorld ]

{ #category : 'accessing' }
CFPhysicsBodyOverlay >> context: aContext [ context := aContext ]

{ #category : 'accessing' }
CFPhysicsBodyOverlay >> visuals [ ^ visualsByBody values asArray ]

{ #category : 'initialization' }
CFPhysicsBodyOverlay >> initializeOverlay [ visualsByBody := IdentityDictionary new ]

{ #category : 'updating' }
CFPhysicsBodyOverlay >> update [
	| bodies live |
	bodies := world bodyStatesInOrder.
	live := IdentitySet new.
	live addAll: bodies.
	(visualsByBody keys reject: [ :each | live includes: each ]) do: [ :body |
		(visualsByBody removeKey: body) release ].
	bodies do: [ :body |
		| visual |
		visual := visualsByBody at: body ifAbsentPut: [
			(CFPhysicsBodyVisual diagnosticOn: body context: context)
				addTo: root;
				yourself ].
		visual update ].
	^ self
]

{ #category : 'controlling' }
CFPhysicsBodyOverlay >> clear [
	visualsByBody valuesDo: #release.
	visualsByBody removeAll.
	^ self
]

{ #category : 'controlling' }
CFPhysicsBodyOverlay >> release [ ^ self clear ]
