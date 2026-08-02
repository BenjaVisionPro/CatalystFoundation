Extension { #name : 'CFPhysicsWorld' }

{ #category : '*BVC-Physics-Tools' }
CFPhysicsWorld >> gtProfileFor: aView [
	<gtView>
	^ aView explicit
		title: 'Profile';
		priority: 21;
		stencil: [ CFPhysicsProfileElement world: self ];
		actionUpdateButtonTooltip: 'Refresh profile'
]
