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
BlElement >> gtShowPhysicsOverlayFor: anAction [
	<gtAction>
	((self existingPhysics notNil and: [ self existingPhysics isWorld ])
		and: [ self existingPhysicsOverlay isNil ])
		ifFalse: [ ^ anAction noAction ].
	^ anAction button
		icon: BrGlamorousVectorIcons inspect;
		tooltip: 'Show physics overlay';
		action: [ self showPhysicsOverlay ]
]

{ #category : '*BVC-Foundation-Physics-Tools' }
BlElement >> gtHidePhysicsOverlayFor: anAction [
	<gtAction>
	self existingPhysicsOverlay ifNil: [ ^ anAction noAction ].
	^ anAction button
		icon: BrGlamorousVectorIcons cancel;
		tooltip: 'Hide physics overlay';
		action: [ self hidePhysicsOverlay ]
]
