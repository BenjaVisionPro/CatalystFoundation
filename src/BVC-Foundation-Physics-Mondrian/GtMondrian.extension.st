Extension { #name : 'GtMondrian' }

{ #category : '*BVC-Foundation-Physics-Mondrian' }
GtMondrian >> physics [
	^ self root userData
		at: CFPhysicsMondrian
		ifAbsentPut: [ CFPhysicsMondrian on: self ]
]
