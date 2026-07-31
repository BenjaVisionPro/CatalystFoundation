Extension { #name : 'CFPhysicsBodyStepState' }

{ #category : '*bvc-physics-tools' }
CFPhysicsBodyStepState >> gtStepStateFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Step state';
		priority: 1;
		items: [ {
			'Body' -> self body.
			'Body origin' -> self currentBodyOrigin.
			'Rotation' -> self body rotation.
			'Linear velocity' -> self linearVelocity.
			'Angular velocity' -> self angularVelocity.
			'Body-origin delta' -> self deltaPosition.
			'Rotation delta' -> self deltaRotation } ];
		column: 'Property' text: #key;
		column: 'Value' text: #value;
		send: #value
]
