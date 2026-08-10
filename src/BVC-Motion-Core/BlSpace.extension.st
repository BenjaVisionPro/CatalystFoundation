Extension { #name : 'BlSpace' }

{ #category : '*BVC-Motion-Core' }
BlSpace >> motionCoordinator [
	^ self root userData
		at: CFMotionCoordinator
		ifAbsentPut: [ CFMotionCoordinator on: self ]
]
