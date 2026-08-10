Extension { #name : 'BlSpace' }

{ #category : '*BVC-Foundation-Motion-Core' }
BlSpace >> motionCoordinator [
	^ self root userData
		at: CFMotionCoordinator
		ifAbsentPut: [ CFMotionCoordinator on: self ]
]
