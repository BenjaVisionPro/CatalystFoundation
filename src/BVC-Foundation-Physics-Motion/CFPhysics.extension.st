Extension { #name : 'CFPhysics' }

{ #category : '*BVC-Foundation-Physics-Motion' }
CFPhysics >> breathing [
	| forceDirectedBehaviour |
	forceDirectedBehaviour := behaviours
		detect: [ :each | each isKindOf: CFPhysicsForceDirectedBehaviour ]
		ifNone: [ self error: 'Breathing needs an existing force-directed Behaviour' ].
	^ self breathingUsing: forceDirectedBehaviour
]

{ #category : '*BVC-Foundation-Physics-Motion' }
CFPhysics >> breathingUsing: aForceDirectedBehaviour [
	^ self addBehaviour: ((CFPhysicsBreathingBehaviour physics: self)
		forceDirected: aForceDirectedBehaviour;
		yourself)
]

{ #category : '*BVC-Foundation-Physics-Motion' }
CFPhysics >> wind [
	^ self addBehaviour: (CFPhysicsWindBehaviour physics: self)
]

{ #category : '*BVC-Foundation-Physics-Motion' }
CFPhysics >> windAffecting: aCollectionOrProvider [
	^ self addBehaviour: ((CFPhysicsWindBehaviour physics: self)
		affecting: aCollectionOrProvider;
		yourself)
]
