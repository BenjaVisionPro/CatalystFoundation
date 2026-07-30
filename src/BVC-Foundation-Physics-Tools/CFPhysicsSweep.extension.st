Extension { #name : 'CFPhysicsSweep' }

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsSweep >> gtMotionFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Motion';
		priority: 1;
		items: [ {
			'Start body origin' -> self startTransform bodyOrigin.
			'Start rotation' -> self startTransform rotation.
			'End body origin' -> self endTransform bodyOrigin.
			'End rotation' -> self endTransform rotation } ];
		column: 'Property' text: #key;
		column: 'Value' text: #value;
		send: #value
]
