Extension { #name : 'CFPhysicsBodyStepState' }

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsBodyStepState >> gtStepStateFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Step state';
		priority: 1;
		items: [ {
			'Body' -> self body.
			'Position' -> self body position.
			'Rotation' -> self body rotation.
			'Linear velocity' -> self linearVelocity.
			'Angular velocity' -> self angularVelocity.
			'Position delta' -> self deltaPosition.
			'Rotation delta' -> self deltaRotation } ];
		column: 'Property' text: #key;
		column: 'Value' text: #value;
		send: #value
]
