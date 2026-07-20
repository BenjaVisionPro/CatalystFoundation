Extension { #name : 'CFPhysicsSweep' }

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsSweep >> gtMotionFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Motion';
		priority: 1;
		items: [ {
			'Start position' -> self startTransform position.
			'Start rotation' -> self startTransform rotation.
			'End position' -> self endTransform position.
			'End rotation' -> self endTransform rotation } ];
		column: 'Property' text: #key;
		column: 'Value' text: #value;
		send: #value
]
