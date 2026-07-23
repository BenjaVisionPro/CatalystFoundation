Extension { #name : 'CFPhysics' }

{ #category : 'behaviours' }
CFPhysics >> breathing [
	| forceDirectedBehaviour |
	forceDirectedBehaviour := behaviours
		detect: [ :each | each isKindOf: CFPhysicsForceDirectedBehaviour ]
		ifNone: [ self error: 'Breathing needs an existing force-directed Behaviour' ].
	^ self breathingUsing: forceDirectedBehaviour
]

{ #category : 'behaviours' }
CFPhysics >> breathingUsing: aForceDirectedBehaviour [
	^ self addBehaviour: ((CFPhysicsBreathingBehaviour physics: self)
		forceDirected: aForceDirectedBehaviour;
		yourself)
]

{ #category : 'behaviours' }
CFPhysics >> wind [
	^ self addBehaviour: (CFPhysicsWindBehaviour physics: self)
]

{ #category : 'behaviours' }
CFPhysics >> windAffecting: aCollectionOrProvider [
	^ self addBehaviour: ((CFPhysicsWindBehaviour physics: self)
		affecting: aCollectionOrProvider;
		yourself)
]
