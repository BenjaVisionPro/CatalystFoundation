Class {
	#name : 'BaselineOfCatalystMotion',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfCatalystMotion',
	#package : 'BaselineOfCatalystMotion'
}

{ #category : 'baseline' }
BaselineOfCatalystMotion >> baseline: spec [
	<baseline>
	spec for: #common do: [
		self definePackagesOn: spec.
		self defineGroupsOn: spec ]
]

{ #category : 'baseline' }
BaselineOfCatalystMotion >> definePackagesOn: spec [
	spec package: 'BVC-Motion-Core'.
	spec package: 'BVC-Motion-Examples'
		with: [ spec requires: #('BVC-Motion-Core') ].
	spec package: 'BVC-Motion-Tests'
		with: [ spec requires: #('BVC-Motion-Core') ]
]

{ #category : 'baseline' }
BaselineOfCatalystMotion >> defineGroupsOn: spec [
	spec group: 'core' with: #('BVC-Motion-Core').
	spec group: 'examples' with: #('core' 'BVC-Motion-Examples').
	spec group: 'tests' with: #('core' 'BVC-Motion-Tests').
	spec group: 'all' with: #('examples' 'tests').
	spec group: 'default' with: #('all')
]
