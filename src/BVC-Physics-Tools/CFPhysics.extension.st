Extension { #name : 'CFPhysics' }

{ #category : '*bvc-physics-tools' }
CFPhysics >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsBodyInspectorContent newContent
]

{ #category : '*bvc-physics-tools' }
CFPhysics >> bodyTypeName [
	self isDynamic ifTrue: [ ^ 'Dynamic' ].
	self isKinematic ifTrue: [ ^ 'Kinematic' ].
	self isStatic ifTrue: [ ^ 'Static' ].
	^ self bodyType class name
]

{ #category : '*bvc-physics-tools' }
CFPhysics >> descriptionAngularVelocity [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #angularVelocity;
		label: 'Angular velocity';
		priority: 90;
		group: 'Motion';
		beReadOnly;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysics >> descriptionAwake [
	<magritteDescription>
	^ MABooleanDescription new
		accessor: #isAwake;
		label: 'Awake';
		priority: 20;
		group: 'State';
		beReadOnly;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysics >> descriptionBodyType [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #bodyTypeName;
		label: 'Body type';
		priority: 10;
		group: 'State';
		beReadOnly;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysics >> descriptionDensity [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #density;
		label: 'Density';
		priority: 40;
		group: 'Material';
		beReadOnly;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysics >> descriptionFriction [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #friction;
		label: 'Friction';
		priority: 50;
		group: 'Material';
		beReadOnly;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysics >> descriptionRestitution [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #restitution;
		label: 'Restitution';
		priority: 60;
		group: 'Material';
		beReadOnly;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysics >> descriptionSensor [
	<magritteDescription>
	^ MABooleanDescription new
		accessor: #isSensor;
		label: 'Sensor';
		priority: 30;
		group: 'State';
		beReadOnly;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysics >> descriptionVelocityX [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #velocityX;
		label: 'Velocity X';
		priority: 70;
		group: 'Motion';
		beReadOnly;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysics >> descriptionVelocityY [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #velocityY;
		label: 'Velocity Y';
		priority: 80;
		group: 'Motion';
		beReadOnly;
		yourself
]

{ #category : '*bvc-physics-tools' }
CFPhysics >> velocityX [
	^ self velocity x
]

{ #category : '*bvc-physics-tools' }
CFPhysics >> velocityY [
	^ self velocity y
]
