"
I manage the retained body diagnostics for one Physics overlay. My responsibility is to reconcile the world's bodies with their visual representations and release those visuals with the overlay.
"
Class {
	#name : 'CFPhysicsBodyOverlay',
	#superclass : 'Object',
	#instVars : [
		'root',
		'world',
		'context',
		'visualsByBody'
	],
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

{ #category : 'controlling' }
CFPhysicsBodyOverlay >> clear [
	visualsByBody valuesDo: #release.
	visualsByBody removeAll.
	^ self
]

{ #category : 'accessing' }
CFPhysicsBodyOverlay >> context: aContext [ context := aContext
]

{ #category : 'initialization' }
CFPhysicsBodyOverlay >> initializeOverlay [ visualsByBody := IdentityDictionary new
]

{ #category : 'controlling' }
CFPhysicsBodyOverlay >> release [ ^ self clear
]

{ #category : 'accessing' }
CFPhysicsBodyOverlay >> root: anElement [ root := anElement
]

{ #category : 'updating' }
CFPhysicsBodyOverlay >> update [
	^ self updateFrom: world bodyStatesInOrder
]

{ #category : 'updating' }
CFPhysicsBodyOverlay >> updateFrom: bodies [
	| live |
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

{ #category : 'accessing' }
CFPhysicsBodyOverlay >> visuals [ ^ visualsByBody values asArray
]

{ #category : 'accessing' }
CFPhysicsBodyOverlay >> world: aWorld [ world := aWorld
]
