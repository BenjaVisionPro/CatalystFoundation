Extension { #name : 'CFPhysicsForceDirectedTreeBehaviour' }

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedTreeBehaviour >> descriptionAttractionStrength [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #attractionStrength;
		label: 'Attraction strength';
		group: 'Positioning';
		priority: 85;
		cfSerializable: true;
		yourself
]
