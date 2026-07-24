"
I constrain the first layer of a directed Mondrian graph around one world-space
anchor at the canvas centre.

A single root is joined directly to the centre with zero rest length. Multiple
roots are joined to the same centre at one common radius and are also joined to
their neighbours, forming a regular polygon that is free to rotate around the
centre. Moving a root stretches those joints; the solver returns the root layer
to its central formation.
"
Class {
	#name : 'CFPhysicsMondrianHierarchyBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [
		'nodes',
		'connections',
		'centre',
		'rootSpacing',
		'minimumRootRadius',
		'centreAnchor',
		'currentRoots',
		'radialJoints',
		'ringJoints' ],
	#category : 'BVC-Foundation-Physics-Mondrian',
	#package : 'BVC-Foundation-Physics-Mondrian'
}

{ #category : 'initialization' }
CFPhysicsMondrianHierarchyBehaviour >> initialize [
	super initialize.
	rootSpacing := 12.0.
	minimumRootRadius := 0.0.
	currentRoots := #().
	radialJoints := IdentityDictionary new.
	ringJoints := OrderedCollection new
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
CFPhysicsMondrianHierarchyBehaviour >> rootSpacing [
	^ rootSpacing
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> rootSpacing: aNumber [
	rootSpacing := aNumber asFloat max: 0.0
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> minimumRootRadius [
	^ minimumRootRadius
]

{ #category : 'configuration' }
CFPhysicsMondrianHierarchyBehaviour >> minimumRootRadius: aNumber [
	minimumRootRadius := aNumber asFloat max: 0.0
]

{ #category : 'accessing' }
CFPhysicsMondrianHierarchyBehaviour >> centreAnchor [
	^ centreAnchor
]

{ #category : 'accessing' }
CFPhysicsMondrianHierarchyBehaviour >> roots [
	^ currentRoots copy
]

{ #category : 'accessing' }
CFPhysicsMondrianHierarchyBehaviour >> radialJoints [
	^ radialJoints values asArray
]

{ #category : 'accessing' }
CFPhysicsMondrianHierarchyBehaviour >> ringJoints [
	^ ringJoints asArray
]

{ #category : 'updating' }
CFPhysicsMondrianHierarchyBehaviour >> updateForStep: aPhysicsStep [
	| currentNodes roots radius |
	currentNodes := self nodes.
	roots := self rootsAmong: currentNodes connections: self connections.
	self ensureCentreAnchor.
	centreAnchor point: self centre.
	(self rootsMatch: roots) ifFalse: [ self rebuildJointsFor: roots ].
	roots isEmpty ifTrue: [ ^ self ].
	radius := self radiusFor: roots.
	self tuneRadialJointsTo: radius rootCount: roots size.
	self tuneRingJointsTo: radius rootCount: roots size
]

{ #category : 'private - roots' }
CFPhysicsMondrianHierarchyBehaviour >> rootsAmong: currentNodes connections: currentConnections [
	| nodeSet incoming roots |
	currentNodes isEmpty ifTrue: [ ^ #() ].
	nodeSet := currentNodes asIdentitySet.
	incoming := IdentitySet new.
	currentConnections do: [ :connection |
		((nodeSet includes: connection key) and: [ nodeSet includes: connection value ])
			ifTrue: [ incoming add: connection value ] ].
	roots := currentNodes reject: [ :node | incoming includes: node ].
	^ roots isEmpty
		ifTrue: [ { currentNodes first } ]
		ifFalse: [ roots ]
]

{ #category : 'private - anchors' }
CFPhysicsMondrianHierarchyBehaviour >> ensureCentreAnchor [
	centreAnchor ifNil: [ centreAnchor := self world anchorAt: self centre ]
]

{ #category : 'private - joints' }
CFPhysicsMondrianHierarchyBehaviour >> rootsMatch: roots [
	currentRoots size = roots size ifFalse: [ ^ false ].
	1 to: roots size do: [ :index |
		(currentRoots at: index) == (roots at: index) ifFalse: [ ^ false ] ].
	^ true
]

{ #category : 'private - joints' }
CFPhysicsMondrianHierarchyBehaviour >> rebuildJointsFor: roots [
	self removeJoints.
	currentRoots := roots asArray.
	currentRoots do: [ :root |
		| bodyAnchor joint |
		bodyAnchor := CFPhysicsBodyCentreAnchor on: root physics requireBodyState.
		joint := bodyAnchor distanceJointTo: centreAnchor.
		radialJoints at: root put: joint ].
	self buildRingJointsFor: currentRoots
]

{ #category : 'private - joints' }
CFPhysicsMondrianHierarchyBehaviour >> buildRingJointsFor: roots [
	| count |
	count := roots size.
	count < 2 ifTrue: [ ^ self ].
	count = 2 ifTrue: [
		ringJoints add: ((CFPhysicsBodyCentreAnchor on: roots first physics requireBodyState)
			distanceJointTo: (CFPhysicsBodyCentreAnchor on: roots second physics requireBodyState)).
		^ self ].
	1 to: count do: [ :index |
		| firstRoot secondRoot joint |
		firstRoot := roots at: index.
		secondRoot := roots at: (index \ count) + 1.
		joint := (CFPhysicsBodyCentreAnchor on: firstRoot physics requireBodyState)
			distanceJointTo: (CFPhysicsBodyCentreAnchor on: secondRoot physics requireBodyState).
		ringJoints add: joint ]
]

{ #category : 'private - joints' }
CFPhysicsMondrianHierarchyBehaviour >> removeJoints [
	radialJoints values do: [ :joint | self world removeDistanceJoint: joint ].
	ringJoints do: [ :joint | self world removeDistanceJoint: joint ].
	radialJoints removeAll.
	ringJoints removeAll
]

{ #category : 'private - joints' }
CFPhysicsMondrianHierarchyBehaviour >> tuneRadialJointsTo: radius rootCount: count [
	| restLength |
	restLength := count = 1 ifTrue: [ 0.0 ] ifFalse: [ radius ].
	radialJoints values do: [ :joint |
		joint restLength = restLength ifFalse: [ joint restLength: restLength ] ]
]

{ #category : 'private - joints' }
CFPhysicsMondrianHierarchyBehaviour >> tuneRingJointsTo: radius rootCount: count [
	| chordLength |
	count < 2 ifTrue: [ ^ self ].
	chordLength := count = 2
		ifTrue: [ radius * 2.0 ]
		ifFalse: [ radius * 2.0 * (Float pi / count) sin ].
	ringJoints do: [ :joint |
		joint restLength = chordLength ifFalse: [ joint restLength: chordLength ] ]
]

{ #category : 'private - geometry' }
CFPhysicsMondrianHierarchyBehaviour >> radiusFor: roots [
	| count clearance calculatedRadius |
	count := roots size.
	count < 2 ifTrue: [ ^ 0.0 ].
	clearance := (roots collect: [ :root |
		| extent |
		extent := root physics requireBodyState extent.
		extent x max: extent y ]) max + rootSpacing.
	calculatedRadius := clearance / (2.0 * (Float pi / count) sin).
	^ calculatedRadius max: minimumRootRadius
]

{ #category : 'removing' }
CFPhysicsMondrianHierarchyBehaviour >> removing [
	self removeJoints.
	currentRoots := #().
	centreAnchor := nil
]
