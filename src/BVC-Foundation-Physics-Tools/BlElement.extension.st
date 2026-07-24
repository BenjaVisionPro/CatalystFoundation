Extension { #name : 'BlElement' }

{ #category : '*BVC-Foundation-Physics-Tools' }
BlElement >> existingPhysicsOverlay [
	^ self userData at: CFPhysicsOverlay ifAbsent: [ nil ]
]

{ #category : '*BVC-Foundation-Physics-Tools' }
BlElement >> showPhysicsOverlay [
	| overlay |
	overlay := self existingPhysicsOverlay.
	overlay ifNil: [
		overlay := CFPhysicsOverlay on: self.
		self userData at: CFPhysicsOverlay put: overlay ].
	overlay install.
	^ overlay
]

{ #category : '*BVC-Foundation-Physics-Tools' }
BlElement >> hidePhysicsOverlay [
	| overlay |
	overlay := self existingPhysicsOverlay.
	overlay ifNil: [ ^ self ].
	overlay release.
	self userData removeKey: CFPhysicsOverlay ifAbsent: [ ].
	^ self
]

{ #category : '*BVC-Foundation-Physics-Tools' }
BlElement >> togglePhysicsOverlay [
	^ self existingPhysicsOverlay
		ifNil: [ self showPhysicsOverlay ]
		ifNotNil: [ self hidePhysicsOverlay ]
]

{ #category : '*BVC-Foundation-Physics-Tools' }
BlElement >> physicsOverlayHost [
	^ self
]

{ #category : '*BVC-Foundation-Physics-Tools' }
BlElement >> gtTogglePhysicsOverlayFor: anAction [
	<gtAction>
	^ CFPhysicsOverlay gtToggleActionFor: self action: anAction
]
