Extension { #name : 'CFPhysics' }

{ #category : '*bvc-physics-behaviours' }
CFPhysics >> forceDirected [
	^ self addBehaviour: (CFPhysicsForceDirectedBehaviour physics: self)
]

{ #category : '*bvc-physics-behaviours' }
CFPhysics >> restoreOrientation [
	^ self addBehaviour: (CFPhysicsOrientationRestoringBehaviour physics: self)
]
