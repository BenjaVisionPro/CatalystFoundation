Extension { #name : 'BlElement' }

{ #category : '*BVC-Foundation-Physics-Core' }
BlElement >> existingPhysics [
	^ self userData
		at: CFPhysicsElement
		ifAbsent: [ nil ]
]

{ #category : '*BVC-Foundation-Physics-Core' }
BlElement >> physics [
	^ self userData
		at: CFPhysicsElement
		ifAbsentPut: [ CFPhysicsElement on: self ]
]
