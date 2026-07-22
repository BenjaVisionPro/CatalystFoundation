Extension { #name : 'BlElement' }

{ #category : '*BVC-Foundation-Physics-Core' }
BlElement >> existingPhysics [
	^ self userData
		at: CFPhysics
		ifAbsent: [ nil ]
]

{ #category : '*BVC-Foundation-Physics-Core' }
BlElement >> physics [
	^ self userData
		at: CFPhysics
		ifAbsentPut: [ CFPhysics on: self ]
]
