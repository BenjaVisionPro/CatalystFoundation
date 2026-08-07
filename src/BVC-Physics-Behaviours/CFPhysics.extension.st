Extension { #name : 'CFPhysics' }

{ #category : '*bvc-physics-behaviours' }
CFPhysics >> restoreOrientation [
	^ CFPhysicsOrientationRestoringBehaviour new
		target: element;
		start
]
