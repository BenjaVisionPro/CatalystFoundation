Extension { #name : 'GtMondrian' }

{ #category : '*BVC-Physics-Tools' }
GtMondrian >> physicsOverlayHost [
	^ self root
]

{ #category : '*BVC-Physics-Tools' }
GtMondrian >> gtTogglePhysicsOverlayFor: anAction [
	<gtAction>
	^ CFPhysicsOverlay gtToggleActionFor: self action: anAction
]
