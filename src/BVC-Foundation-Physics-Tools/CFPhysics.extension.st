Extension { #name : 'CFPhysics' }

{ #category : '*bvc-foundation-physics-tools - accessing' }
CFPhysics >> bodyTypeName [
	self isDynamic ifTrue: [ ^ 'Dynamic' ].
	self isKinematic ifTrue: [ ^ 'Kinematic' ].
	self isStatic ifTrue: [ ^ 'Static' ].
	^ self bodyType class name
]

{ #category : '*bvc-foundation-physics-tools - descriptions' }
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

{ #category : '*bvc-foundation-physics-tools - descriptions' }
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

{ #category : '*bvc-foundation-physics-tools - descriptions' }
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

{ #category : '*bvc-foundation-physics-tools - descriptions' }
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

{ #category : '*bvc-foundation-physics-tools - descriptions' }
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

{ #category : '*bvc-foundation-physics-tools - descriptions' }
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

{ #category : '*bvc-foundation-physics-tools - descriptions' }
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

{ #category : '*bvc-foundation-physics-tools - descriptions' }
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

{ #category : '*bvc-foundation-physics-tools - descriptions' }
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

{ #category : '*bvc-foundation-physics-tools - accessing' }
CFPhysics >> velocityX [
	^ self velocity x
]

{ #category : '*bvc-foundation-physics-tools - accessing' }
CFPhysics >> velocityY [
	^ self velocity y
]
