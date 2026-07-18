Extension { #name : 'BlElement' }

{ #category : '*BVC-Foundation-Physics-World' }
BlElement >> existingPhysics [
	^ self userData
		at: CFPhysicsElement
		ifAbsent: [ nil ]
]

{ #category : '*BVC-Foundation-Physics-World' }
BlElement >> physics [
	^ self userData
		at: CFPhysicsElement
		ifAbsentPut: [ CFPhysicsElement on: self ]
]
