Extension { #name : 'GtMondrian' }

{ #category : '*BVC-Foundation-Physics-Mondrian' }
GtMondrian >> edges [
	| physicsMondrian |
	physicsMondrian := self root userData
		at: CFPhysicsMondrian
		ifAbsent: [ nil ].
	^ (physicsMondrian notNil and: [ physicsMondrian world notNil ])
		ifTrue: [ CFPhysicsMondrianEdgeBuilder new mondrian: self ]
		ifFalse: [ GtMondrianEdgeBuilder new mondrian: self ]
]

{ #category : '*BVC-Foundation-Physics-Mondrian' }
GtMondrian >> physics [
	^ self root userData
		at: CFPhysicsMondrian
		ifAbsentPut: [ CFPhysicsMondrian on: self ]
]

{ #category : '*BVC-Foundation-Physics-Mondrian' }
GtMondrian >> physicsOverlayHost [
	^ self root
]

{ #category : '*BVC-Foundation-Physics-Mondrian' }
GtMondrian >> gtTogglePhysicsOverlayFor: anAction [
	<gtAction>
	^ CFPhysicsOverlay gtToggleActionFor: self action: anAction
]
