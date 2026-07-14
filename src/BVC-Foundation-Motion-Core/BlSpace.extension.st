Extension { #name : 'BlSpace' }

{ #category : '*BVC-Foundation-Motion-Core' }
BlSpace >> cfMotionCoordinator [
	^ self root userData
		at: CFMotionCoordinator
		ifAbsentPut: [ CFMotionCoordinator on: self ]
]
