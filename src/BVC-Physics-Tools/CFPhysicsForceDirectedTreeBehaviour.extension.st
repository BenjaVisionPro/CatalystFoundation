Extension { #name : 'CFPhysicsForceDirectedTreeBehaviour' }

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedTreeBehaviour >> descriptionAttractionStiffness [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #attractionStiffness;
		label: 'Attraction stiffness (N/m)';
		group: 'Positioning';
		priority: 85;
		cfSerializable: true;
		yourself
]
