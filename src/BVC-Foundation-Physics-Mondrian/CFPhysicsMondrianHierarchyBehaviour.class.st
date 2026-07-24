"
I guide a directed Mondrian graph into a layered radial shape without replacing
ordinary Physics. Springs, repulsion and collision remain owned by the generic
force-directed behaviour and the world.

Roots settle onto a compact ring around the canvas centre. Each child is given
a target on an outward-facing arc relative to its parent, so every generation
continues away from the centre instead of being pulled back through the graph.
"
Class {
	#name : 'CFPhysicsMondrianHierarchyBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [ 'nodes', 'connections', 'centre', 'rootRadius', 'layerDistance', 'siblingArc', 'restoringStrength', 'velocityDamping' ],
	#category : 'BVC-Foundation-Physics-Mondrian',
	#package : 'BVC-Foundation-Physics-Mondrian'
}

{ #category : 'initialization' }
CFPhysicsMondrianHierarchyBehaviour >> initialize [
	super initialize.
	rootRadius := 42.0.
	layerDistance := 118.0.
	siblingArc := Float pi * 0.62.
	restoringStrength := 5.5.
	velocityDamping := 2.5
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> nodes: aCollectionOrProvider [
	nodes := aCollectionOrProvider.
	^ self
]

{ #category : 'accessing' }
CFPhysicsMondrianHierarchyBehaviour >> nodes [
	^ self resolvedParticipantsFrom: nodes default: [ #() ]
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> connections: aCollectionOrProvider [
	connections := aCollectionOrProvider.
	^ self
]

{ #category : 'accessing' }
CFPhysicsMondrianHierarchyBehaviour >> connections [
	^ self resolvedParticipantsFrom: connections default: [ #() ]
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> centre: aPointOrProvider [
	centre := aPointOrProvider.
	^ self
]

{ #category : 'accessing' }
CFPhysicsMondrianHierarchyBehaviour >> centre [
	^ centre value
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> rootRadius [ ^ rootRadius ]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> rootRadius: aNumber [
	rootRadius := aNumber asFloat max: 0.0
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> layerDistance [ ^ layerDistance ]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> layerDistance: aNumber [
	layerDistance := aNumber asFloat max: 0.0
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> siblingArc [ ^ siblingArc ]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> siblingArc: aNumber [
	siblingArc := aNumber asFloat max: 0.0
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> restoringStrength [ ^ restoringStrength ]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> restoringStrength: aNumber [
	restoringStrength := aNumber asFloat max: 0.0
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> velocityDamping [ ^ velocityDamping ]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> velocityDamping: aNumber [
	velocityDamping := aNumber asFloat max: 0.0
]

{ #category : 'updating' }
CFPhysicsMondrianHierarchyBehaviour >> updateForStep: aPhysicsStep [
	| currentNodes currentConnections targets |
	currentNodes := self nodes.
	currentNodes isEmpty ifTrue: [ ^ self ].
	currentConnections := self connections.
	targets := self
		targetCentresFor: currentNodes
		connections: currentConnections.
	self
		guide: currentNodes
		towards: targets
		over: aPhysicsStep timeStep
]

{ #category : 'private - targets' }
CFPhysicsMondrianHierarchyBehaviour >> targetCentresFor: currentNodes connections: currentConnections [
	| nodeSet incoming childrenByParent roots targets queue |
	nodeSet := currentNodes asIdentitySet.
	incoming := IdentityDictionary new.
	childrenByParent := IdentityDictionary new.
	currentConnections do: [ :connection |
		((nodeSet includes: connection key) and: [ nodeSet includes: connection value ]) ifTrue: [
			incoming at: connection value ifAbsentPut: [ connection key ].
			(childrenByParent at: connection key ifAbsentPut: [ OrderedCollection new ])
				add: connection value ] ].
	roots := currentNodes reject: [ :node | incoming includesKey: node ].
	roots isEmpty ifTrue: [ roots := { currentNodes first } ].
	targets := IdentityDictionary new.
	queue := OrderedCollection new.
	self placeRoots: roots into: targets queue: queue.
	[ queue isEmpty ] whileFalse: [
		| parent children |
		parent := queue removeFirst.
		children := childrenByParent at: parent ifAbsent: [ #() ].
		self
			placeChildren: children
			of: parent
			into: targets
			queue: queue ].
	currentNodes do: [ :node |
		targets at: node ifAbsentPut: [ self centre ] ].
	^ targets
]

{ #category : 'private - targets' }
CFPhysicsMondrianHierarchyBehaviour >> placeRoots: roots into: targets queue: queue [
	| count radius |
	count := roots size.
	radius := count = 1 ifTrue: [ 0.0 ] ifFalse: [ rootRadius ].
	roots withIndexDo: [ :root :index |
		| angle target |
		angle := (Float twoPi * (index - 1) / count) - (Float pi / 2.0).
		target := self centre + ((angle cos @ angle sin) * radius).
		targets at: root put: target.
		queue add: root ]
]

{ #category : 'private - targets' }
CFPhysicsMondrianHierarchyBehaviour >> placeChildren: children of: parent into: targets queue: queue [
	| parentTarget outwardAngle count |
	children isEmpty ifTrue: [ ^ self ].
	parentTarget := targets at: parent.
	outwardAngle := self outwardAngleFromCentreTo: parentTarget for: parent.
	count := children size.
	children withIndexDo: [ :child :index |
		(targets includesKey: child) ifFalse: [
			| offset angle target |
			offset := count = 1
				ifTrue: [ 0.0 ]
				ifFalse: [ siblingArc * ((index - 1) / (count - 1) - 0.5) ].
			angle := outwardAngle + offset.
			target := parentTarget + ((angle cos @ angle sin) * layerDistance).
			targets at: child put: target.
			queue add: child ] ]
]

{ #category : 'private - targets' }
CFPhysicsMondrianHierarchyBehaviour >> outwardAngleFromCentreTo: parentTarget for: parent [
	| displacement |
	displacement := parentTarget - self centre.
	displacement r > 0.001 ifTrue: [ ^ displacement theta ].
	^ (Float twoPi * ((self nodes identityIndexOf: parent ifAbsent: [ 1 ]) - 1)
		/ (self nodes size max: 1)) - (Float pi / 2.0)
]

{ #category : 'private - forces' }
CFPhysicsMondrianHierarchyBehaviour >> guide: currentNodes towards: targets over: seconds [
	| dampingFactor |
	dampingFactor := 1.0 / (1.0 + (seconds * velocityDamping)).
	currentNodes do: [ :element |
		| body targetPosition displacement velocity |
		body := element physics requireBodyState.
		body isDynamic ifTrue: [
			targetPosition := (targets at: element) - (body extent / 2.0).
			displacement := targetPosition - body position.
			velocity := body velocity + (displacement * (restoringStrength * seconds)).
			body velocity: velocity * dampingFactor ] ]
]
