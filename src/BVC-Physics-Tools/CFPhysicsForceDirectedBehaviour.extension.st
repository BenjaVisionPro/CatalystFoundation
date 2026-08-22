Extension { #name : 'CFPhysicsForceDirectedBehaviour' }

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> configurationSourceSetupOn: aStream [
	super configurationSourceSetupOn: aStream.
	aStream
		nextPutAll: '    adapter: anAdapter;';
		cr
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionCentringStiffness [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #centringStiffness;
		label: 'Centring stiffness (N/m)';
		group: 'Positioning';
		priority: 70;
		cfSerializable: true;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionComponentCentringStiffness [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #componentCentringStiffness;
		label: 'Component centring stiffness (N/m)';
		group: 'Positioning';
		priority: 80;
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

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionMaximumRepulsionDistance [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #maximumRepulsionDistance;
		label: 'Maximum distance (m)';
		group: 'Repulsion';
		priority: 60;
		cfSerializable: true;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionOrientationAngleTolerance [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #orientationAngleTolerance;
		label: 'Angle tolerance';
		group: 'Orientation';
		priority: 140;
		cfSerializable: true;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionOrientationAngularResponseVelocityScale [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #orientationAngularResponseVelocityScale;
		label: 'Angular response velocity scale';
		group: 'Orientation';
		priority: 130;
		cfSerializable: true;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionOrientationAngularVelocityTolerance [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #orientationAngularVelocityTolerance;
		label: 'Angular velocity tolerance';
		group: 'Orientation';
		priority: 150;
		cfSerializable: true;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionOrientationDamping [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #orientationDamping;
		label: 'Orientation damping';
		group: 'Orientation';
		priority: 110;
		cfSerializable: true;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionOrientationMaximumAngularAcceleration [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #orientationMaximumAngularAcceleration;
		label: 'Maximum angular acceleration';
		group: 'Orientation';
		priority: 120;
		cfSerializable: true;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionOrientationStiffness [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #orientationStiffness;
		label: 'Orientation stiffness';
		group: 'Orientation';
		priority: 100;
		cfSerializable: true;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysicsForceDirectedBehaviour >> descriptionRepulsionAtOneMetre [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #repulsionAtOneMetre;
		label: 'Repulsion at 1 m (N)';
		group: 'Repulsion';
		priority: 40;
		cfSerializable: true;
		yourself
]
