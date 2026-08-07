Extension { #name : 'CFPhysicsForceDirectedBehaviour' }

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> configurationSourceSetupOn: aStream [
	super configurationSourceSetupOn: aStream.
	aStream
		nextPutAll: '    adapter: anAdapter;';
		cr
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionLength [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #length;
		label: 'Link length';
		group: 'Links';
		priority: 10;
		cfSerializable: true;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionHertz [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #hertz;
		label: 'Link hertz';
		group: 'Links';
		priority: 20;
		cfSerializable: true;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionDampingRatio [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #dampingRatio;
		label: 'Link damping ratio';
		group: 'Links';
		priority: 30;
		cfSerializable: true;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionRepulsion [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #repulsion;
		label: 'Repulsion';
		group: 'Repulsion';
		priority: 40;
		cfSerializable: true;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionRepulsionSofteningDistance [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #repulsionSofteningDistance;
		label: 'Softening distance';
		group: 'Repulsion';
		priority: 50;
		cfSerializable: true;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionMaximumRepulsionDistance [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #maximumRepulsionDistance;
		label: 'Maximum distance';
		group: 'Repulsion';
		priority: 60;
		cfSerializable: true;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionCentringStrength [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #centringStrength;
		label: 'Centring strength';
		group: 'Positioning';
		priority: 70;
		cfSerializable: true;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionComponentCentringStrength [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #componentCentringStrength;
		label: 'Component centring strength';
		group: 'Positioning';
		priority: 80;
		cfSerializable: true;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionLinearDamping [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #linearDamping;
		label: 'Linear damping';
		group: 'Bodies';
		priority: 90;
		cfSerializable: true;
		yourself
]
