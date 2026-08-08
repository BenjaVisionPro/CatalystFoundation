Class {
	#name : 'CFPhysicsBehaviourInspectorTests',
	#superclass : 'TestCase',
	#category : 'BVC-Physics-Tests-Tools',
	#package : 'BVC-Physics-Tests-Tools'
}

{ #category : 'tests' }
CFPhysicsBehaviourInspectorTests >> testForceDirectedConfigurationDescriptionsAreEditableAndSerializable [
	| behaviour descriptions expected |
	behaviour := CFPhysicsForceDirectedBehaviour new.
	descriptions := behaviour configurationDescriptions.
	expected := #(length hertz dampingRatio repulsionAtOneMetre maximumRepulsionDistance centringStiffness componentCentringStiffness linearDamping orientationStiffness orientationDamping orientationMaximumAngularAcceleration orientationAngularResponseVelocityScale orientationAngleTolerance orientationAngularVelocityTolerance).
	self assert: (descriptions collect: [ :each | each accessor selector ]) asArray equals: expected.
	self assert: (descriptions allSatisfy: #cfSerializable).
	self assert: (descriptions noneSatisfy: #isReadOnly)
]

{ #category : 'tests' }
CFPhysicsBehaviourInspectorTests >> testForceDirectedConfigurationSourceUsesCurrentValues [
	| behaviour source |
	behaviour := CFPhysicsForceDirectedBehaviour new
		length: 123.0;
		repulsionAtOneMetre: 0.7;
		componentCentringStiffness: 0.0035;
		yourself.
	source := behaviour configurationSource.
	self assert: (source includesSubstring: 'CFPhysicsForceDirectedBehaviour new').
	self assert: (source includesSubstring: 'target: aTarget;').
	self assert: (source includesSubstring: 'adapter: anAdapter;').
	self assert: (source includesSubstring: 'length: 123.0;').
	self assert: (source includesSubstring: 'repulsionAtOneMetre: 0.7;').
	self assert: (source includesSubstring: 'componentCentringStiffness: 0.0035;').
	self assert: (source endsWith: 'start')
]

{ #category : 'tests' }
CFPhysicsBehaviourInspectorTests >> testTreeConfigurationIncludesInheritedAndTreeSpecificValues [
	| behaviour descriptions source |
	behaviour := CFPhysicsForceDirectedTreeBehaviour new attractionStiffness: 0.0222; yourself.
	descriptions := behaviour configurationDescriptions.
	self assert: (descriptions anySatisfy: [ :each | each accessor selector = #length ]).
	self assert: (descriptions anySatisfy: [ :each | each accessor selector = #attractionStiffness ]).
	source := behaviour configurationSource.
	self assert: (source includesSubstring: 'CFPhysicsForceDirectedTreeBehaviour new').
	self assert: (source includesSubstring: 'attractionStiffness: 0.0222;')
]

{ #category : 'tests' }
CFPhysicsBehaviourInspectorTests >> testWorldBehaviourRevisionChangesOnlyWhenMembershipChanges [
	| host world behaviour initialRevision |
	host := BlElement new.
	host physics beWorld.
	world := host physics world.
	behaviour := CFPhysicsBehaviour new target: host.
	initialRevision := world behaviourRevision.
	behaviour start.
	self assert: world behaviourRevision equals: initialRevision + 1.
	behaviour start.
	self assert: world behaviourRevision equals: initialRevision + 1.
	behaviour stop.
	self assert: world behaviourRevision equals: initialRevision + 2.
	behaviour stop.
	self assert: world behaviourRevision equals: initialRevision + 2
]


{ #category : 'tests' }
CFPhysicsBehaviourInspectorTests >> testForceDirectedExposesSharedOrientationConfiguration [
	| behaviour |
	behaviour := CFPhysicsForceDirectedBehaviour new
		orientationStiffness: 42.0;
		orientationDamping: 7.0;
		yourself.
	self assert: behaviour orientationStiffness equals: 42.0.
	self assert: behaviour orientationDamping equals: 7.0.
	self assert: (behaviour configurationSource includesSubstring: 'orientationStiffness: 42.0;').
	self assert: (behaviour configurationSource includesSubstring: 'orientationDamping: 7.0;')
]

{ #category : 'tests' }
CFPhysicsBehaviourInspectorTests >> testBehaviourOverlayInspectorWritesLiveNumericValue [
	| behaviour description content control |
	behaviour := CFPhysicsForceDirectedBehaviour new.
	description := behaviour configurationDescriptions detect: [ :each | each accessor selector = #length ].
	content := CFPhysicsBehaviourInspector newContent.
	content inspect: behaviour.
	control := (content instVarNamed: 'controlsByDescription') at: description.
	description write: 123.0 to: behaviour.
	control refresh.
	self assert: behaviour length equals: 123.0.
	self assert: control editor text asString equals: '123.0'
]
