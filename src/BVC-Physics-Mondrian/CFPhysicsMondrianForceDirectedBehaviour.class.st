"
I orchestrate force-directed Physics for one Mondrian graph.

My responsibility is to install, configure and remove the generic force-directed, hierarchy and orientation Behaviours and the body profile they require.
"
Class {
	#name : 'CFPhysicsMondrianForceDirectedBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [
		'forceDirectedBehaviour',
		'hierarchyBehaviour',
		'orientationBehavioursByNode',
		'originalDensityByNode',
		'originalAngularDampingByNode',
		'nodeDensity',
		'nodeAngularDamping',
		'orientationStiffness',
		'orientationDamping',
		'orientationResponseVelocityScale',
		'orientationMaximumAngularAcceleration'
	],
	#category : 'BVC-Physics-Mondrian',
	#package : 'BVC-Physics-Mondrian'
}

{ #category : 'accessing' }
CFPhysicsMondrianForceDirectedBehaviour >> mondrian [
	^ physics mondrian
]

{ #category : 'initialization' }
CFPhysicsMondrianForceDirectedBehaviour >> initialize [
	super initialize.
	orientationBehavioursByNode := IdentityDictionary new.
	originalDensityByNode := IdentityDictionary new.
	originalAngularDampingByNode := IdentityDictionary new.
	nodeDensity := CFPhysicsSharedScalar value: 2.5.
	nodeAngularDamping := CFPhysicsSharedScalar value: 3.0.
	orientationStiffness := CFPhysicsSharedScalar value: 36.0.
	orientationDamping := CFPhysicsSharedScalar value: 6.0.
	orientationResponseVelocityScale := CFPhysicsSharedScalar value: 4.0.
	orientationMaximumAngularAcceleration := CFPhysicsSharedScalar value: 30.0
]

{ #category : 'installation' }
CFPhysicsMondrianForceDirectedBehaviour >> install [
	forceDirectedBehaviour := self mondrian root physics forceDirected.
	forceDirectedBehaviour
		nodes: [ physics mondrian nodeElements ];
		connections: [ physics forceDirectedConnections ];
		length: 104.0;
		hertz: 3.0;
		dampingRatio: 1.0;
		repulsion: 72000.0;
		repulsionSofteningDistance: 58.0;
		maximumRepulsionDistance: 175.0;
		velocityDamping: 10.0.
	hierarchyBehaviour := self mondrian root physics addBehaviour:
		(CFPhysicsMondrianHierarchyBehaviour physics: self mondrian root physics).
	hierarchyBehaviour
		nodes: [ physics mondrian nodeElements ];
		connections: [ physics forceDirectedConnections ];
		centre: [ self mondrian root extent / 2.0 ].
	self synchroniseNodeBehaviours.
	^ self
]

{ #category : 'updating' }
CFPhysicsMondrianForceDirectedBehaviour >> updateForStep: aPhysicsStep [
	self synchroniseNodeBehaviours
]

{ #category : 'private - nodes' }
CFPhysicsMondrianForceDirectedBehaviour >> synchroniseNodeBehaviours [
	| currentNodes currentSet |
	currentNodes := physics mondrian nodeElements.
	currentSet := currentNodes asIdentitySet.
	orientationBehavioursByNode keys copy do: [ :node |
		(currentSet includes: node) ifFalse: [ self removeNode: node ] ].
	currentNodes do: [ :node |
		(orientationBehavioursByNode includesKey: node) ifFalse: [
			self installNode: node ] ]
]

{ #category : 'private - nodes' }
CFPhysicsMondrianForceDirectedBehaviour >> installNode: node [
	| body orientation |
	body := node physics body.
	originalDensityByNode at: node put: body density.
	originalAngularDampingByNode at: node put: body angularDamping.
	body
		density: nodeDensity value;
		angularDamping: nodeAngularDamping value.
	orientation := node physics restoreOrientation.
	orientation
		stiffness: orientationStiffness;
		damping: orientationDamping;
		angularResponseVelocityScale: orientationResponseVelocityScale;
		maximumAngularAcceleration: orientationMaximumAngularAcceleration.
	orientationBehavioursByNode at: node put: orientation
]

{ #category : 'private - nodes' }
CFPhysicsMondrianForceDirectedBehaviour >> removeNode: node [
	| body |
	(orientationBehavioursByNode removeKey: node ifAbsent: [ nil ])
		ifNotNil: [ :orientation | orientation remove ].
	body := node existingPhysics ifNil: [ nil ] ifNotNil: [ :each | each bodyOrNil ].
	body ifNotNil: [
		(originalDensityByNode removeKey: node ifAbsent: [ nil ])
			ifNotNil: [ :value | body density: value ].
		(originalAngularDampingByNode removeKey: node ifAbsent: [ nil ])
			ifNotNil: [ :value | body angularDamping: value ] ] ifNil: [
		originalDensityByNode removeKey: node ifAbsent: [ ].
		originalAngularDampingByNode removeKey: node ifAbsent: [ ] ]
]

{ #category : 'accessing' }
CFPhysicsMondrianForceDirectedBehaviour >> orientationBehaviours [
	^ orientationBehavioursByNode values copy
]

{ #category : 'accessing' }
CFPhysicsMondrianForceDirectedBehaviour >> forceDirectedBehaviour [ ^ forceDirectedBehaviour ]

{ #category : 'accessing' }
CFPhysicsMondrianForceDirectedBehaviour >> hierarchyBehaviour [ ^ hierarchyBehaviour ]

{ #category : 'removing' }
CFPhysicsMondrianForceDirectedBehaviour >> removing [
	orientationBehavioursByNode keys copy do: [ :node | self removeNode: node ].
	hierarchyBehaviour ifNotNil: [ hierarchyBehaviour remove ].
	forceDirectedBehaviour ifNotNil: [ forceDirectedBehaviour remove ]
]
