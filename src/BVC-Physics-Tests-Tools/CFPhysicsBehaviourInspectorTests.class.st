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
	expected := #(length hertz dampingRatio repulsion repulsionSofteningDistance maximumRepulsionDistance centringStrength componentCentringStrength linearDamping).
	self assert: (descriptions collect: [ :each | each accessor selector ]) asArray equals: expected.
	self assert: (descriptions allSatisfy: #cfSerializable).
	self assert: (descriptions noneSatisfy: #isReadOnly)
]

{ #category : 'tests' }
CFPhysicsBehaviourInspectorTests >> testForceDirectedConfigurationSourceUsesCurrentValues [
	| behaviour source |
	behaviour := CFPhysicsForceDirectedBehaviour new
		length: 123.0;
		repulsion: 456789.0;
		componentCentringStrength: 3.5;
		yourself.
	source := behaviour configurationSource.
	self assert: (source includesSubstring: 'CFPhysicsForceDirectedBehaviour new').
	self assert: (source includesSubstring: 'target: aTarget;').
	self assert: (source includesSubstring: 'adapter: anAdapter;').
	self assert: (source includesSubstring: 'length: 123.0;').
	self assert: (source includesSubstring: 'repulsion: 456789.0;').
	self assert: (source includesSubstring: 'componentCentringStrength: 3.5;').
	self assert: (source endsWith: 'start')
]

{ #category : 'tests' }
CFPhysicsBehaviourInspectorTests >> testTreeConfigurationIncludesInheritedAndTreeSpecificValues [
	| behaviour descriptions source |
	behaviour := CFPhysicsForceDirectedTreeBehaviour new attractionStrength: 222.0; yourself.
	descriptions := behaviour configurationDescriptions.
	self assert: (descriptions anySatisfy: [ :each | each accessor selector = #length ]).
	self assert: (descriptions anySatisfy: [ :each | each accessor selector = #attractionStrength ]).
	source := behaviour configurationSource.
	self assert: (source includesSubstring: 'CFPhysicsForceDirectedTreeBehaviour new').
	self assert: (source includesSubstring: 'attractionStrength: 222.0;')
]
