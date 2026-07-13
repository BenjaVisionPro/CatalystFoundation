Class {
	#name : 'BaselineOfCatalystFoundation',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfCatalystFoundation',
	#package : 'BaselineOfCatalystFoundation'
}

{ #category : 'loading' }
BaselineOfCatalystFoundation class >> loadLepiter [
	IceRepository registry  
		detect: [ :aRepository |
			aRepository name = 'CatalystFoundation' ]
		ifFound: [ :aRepository | 
			| defaultDatabase currentProperties |
			defaultDatabase := LeDatabasesRegistry defaultLogicalDatabase.
			currentProperties := defaultDatabase properties.
			currentProperties addRegisteredDirectory: aRepository repositoryDirectory / 'lepiter'.
			defaultDatabase reload ]
		ifNone: [
			self inform: 'Repository not found.' ]
]

{ #category : 'baseline' }
BaselineOfCatalystFoundation >> baseline: spec [
	<baseline>
	spec for: #common do: [
		self defineCommonPackagesOn: spec.
		self defineCommonGroupsOn: spec ].
	spec for: #pharo do: [
		self definePharoPackagesOn: spec.
		self definePharoGroupsOn: spec ].
	spec for: #gemstone do: [ self defineGemStoneGroupsOn: spec ]
]

{ #category : 'baseline' }
BaselineOfCatalystFoundation >> defineCommonGroupsOn: spec [
	spec group: 'foundation-common' with: #(
		'BVC-Foundation-Core'
		'BVC-Foundation-Magritte-Core'
		'BVC-Foundation-Config-Core'
		'BVC-Foundation-Config-Validation'
		'BVC-Foundation-Config-Library'
		'BVC-Foundation-Config-Planner'
		'BVC-Foundation-Config-Examples'
	)
]

{ #category : 'baseline' }
BaselineOfCatalystFoundation >> defineCommonPackagesOn: spec [
	spec package: 'BVC-Foundation-Core'.
	spec package: 'BVC-Foundation-Magritte-Core'
		with: [ spec requires: #('BVC-Foundation-Core') ].
	spec package: 'BVC-Foundation-Config-Core'
		with: [ spec requires: #('BVC-Foundation-Core' 'BVC-Foundation-Magritte-Core') ].
	spec package: 'BVC-Foundation-Config-Validation'
		with: [ spec requires: #('BVC-Foundation-Config-Core' 'BVC-Foundation-Magritte-Core') ].
	spec package: 'BVC-Foundation-Config-Library'
		with: [ spec requires: #('BVC-Foundation-Config-Core') ].
	spec package: 'BVC-Foundation-Config-Planner'
		with: [ spec requires: #('BVC-Foundation-Config-Core' 'BVC-Foundation-Config-Validation' 'BVC-Foundation-Config-Library') ].
	spec package: 'BVC-Foundation-Config-Examples'
		with: [ spec requires: #('BVC-Foundation-Config-Validation' 'BVC-Foundation-Config-Library' 'BVC-Foundation-Config-Planner') ]
]

{ #category : 'baseline' }
BaselineOfCatalystFoundation >> defineGemStoneGroupsOn: spec [
	spec group: 'default' with: #('foundation-common')
]

{ #category : 'baseline' }
BaselineOfCatalystFoundation >> definePharoGroupsOn: spec [
	spec group: 'ui' with: #(
		'BVC-Foundation-UI-Animation'
		'BVC-Foundation-Magritte-GT'
		'BVC-Foundation-Magritte-Seaside'
		'BVC-Foundation-Config-UI-Core'
		'BVC-Foundation-Config-UI-ConfigurationEditor'
	).
	spec group: 'default' with: #('foundation-common' 'ui')
]

{ #category : 'baseline' }
BaselineOfCatalystFoundation >> definePharoPackagesOn: spec [
	spec
		baseline: 'Gt4FontAwesome'
		with: [ spec repository: 'git@github.com:BenjaVisionPro/gt4FontAwesome.git' ].
	spec package: 'BVC-Foundation-UI-Animation'.
	spec package: 'BVC-Foundation-Magritte-GT'
		with: [ spec requires: #('BVC-Foundation-Magritte-Core' 'Gt4FontAwesome') ].
	spec package: 'BVC-Foundation-Magritte-Seaside'
		with: [ spec requires: #('BVC-Foundation-Magritte-Core') ].
	spec package: 'BVC-Foundation-Config-UI-Core'
		with: [ spec requires: #('BVC-Foundation-Config-Validation' 'BVC-Foundation-Config-Library' 'BVC-Foundation-Magritte-GT') ].
	spec package: 'BVC-Foundation-Config-UI-ConfigurationEditor'
		with: [ spec requires: #('BVC-Foundation-Config-UI-Core' 'BVC-Foundation-Config-Planner' 'BVC-Foundation-UI-Animation') ]
]
