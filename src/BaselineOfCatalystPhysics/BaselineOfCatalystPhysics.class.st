Class {
	#name : 'BaselineOfCatalystPhysics',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfCatalystPhysics',
	#package : 'BaselineOfCatalystPhysics'
}

{ #category : 'baseline' }
BaselineOfCatalystPhysics >> baseline: spec [
	<baseline>
	spec for: #common do: [
		self defineDependenciesOn: spec.
		self definePackagesOn: spec.
		self defineGroupsOn: spec ]
]

{ #category : 'baseline' }
BaselineOfCatalystPhysics >> defineDependenciesOn: spec [
	spec
		baseline: 'CatalystMotion'
		with: [
			spec
				loads: #('core');
				repository: 'github://BenjaVisionPro/CatalystFoundation:main/src' ].
	spec
		baseline: 'Telemetry'
		with: [ spec repository: 'github://feenkcom/pharo-telemetry:main/src' ].
	spec
		baseline: 'Gt4FontAwesome'
		with: [ spec repository: 'git@github.com:BenjaVisionPro/gt4FontAwesome.git' ]
]

{ #category : 'baseline' }
BaselineOfCatalystPhysics >> definePackagesOn: spec [
	"Foundation GT dependencies remain temporary until GT support migrates."
	spec package: 'BVC-Foundation-Core'.
	spec package: 'BVC-Foundation-Magritte-Core'
		with: [ spec requires: #('BVC-Foundation-Core') ].
	spec package: 'BVC-Foundation-Magritte-GT'
		with: [ spec requires: #('BVC-Foundation-Magritte-Core' 'Gt4FontAwesome') ].
	spec package: 'BVC-Physics-Model'.
	spec package: 'BVC-Physics-Collision'
		with: [ spec requires: #('BVC-Physics-Model') ].
	spec package: 'BVC-Physics-Pipeline'
		with: [ spec requires: #('BVC-Physics-Model' 'BVC-Physics-Collision') ].
	spec package: 'BVC-Physics-Bloc'
		with: [ spec requires: #('BVC-Physics-Model' 'BVC-Physics-Collision') ].
	spec package: 'BVC-Physics-Core'
		with: [ spec requires: #(
			'BVC-Physics-Model'
			'BVC-Physics-Collision'
			'BVC-Physics-Pipeline'
			'BVC-Physics-Bloc'
			'Telemetry') ].
	spec package: 'BVC-Physics-Behaviours'
		with: [ spec requires: #('BVC-Physics-Core') ].
	spec package: 'BVC-Physics-Motion'
		with: [ spec requires: #('CatalystMotion' 'BVC-Physics-Core') ].
	spec package: 'BVC-Physics-Tools'
		with: [ spec requires: #('BVC-Physics-Core' 'BVC-Physics-Behaviours' 'BVC-Physics-Pipeline' 'BVC-Physics-Motion' 'BVC-Foundation-Magritte-GT') ].
	spec package: 'BVC-Physics-Mondrian'
		with: [ spec requires: #('BVC-Physics-Core' 'BVC-Physics-Behaviours' 'BVC-Physics-Motion') ].
	spec package: 'BVC-Physics-Examples'
		with: [ spec requires: #('BVC-Physics-Core' 'BVC-Physics-Behaviours' 'BVC-Physics-Motion' 'BVC-Physics-Mondrian' 'BVC-Physics-Tools') ].

	spec package: 'BVC-Physics-Tests-Core'
		with: [ spec requires: #('BVC-Physics-Core' 'BVC-Physics-Pipeline' 'BVC-Physics-Bloc' 'BVC-Physics-Motion' 'BVC-Physics-Tools') ].
	spec package: 'BVC-Physics-Tests-Behaviours'
		with: [ spec requires: #('BVC-Physics-Tests-Core' 'BVC-Physics-Behaviours' 'BVC-Physics-Pipeline' 'BVC-Physics-Motion') ].
	spec package: 'BVC-Physics-Tests-Mondrian'
		with: [ spec requires: #('BVC-Physics-Mondrian' 'BVC-Physics-Examples') ].
	spec package: 'BVC-Physics-Tests-Tools'
		with: [ spec requires: #('BVC-Physics-Tools' 'BVC-Physics-Behaviours' 'BVC-Physics-Mondrian') ]
]

{ #category : 'baseline' }
BaselineOfCatalystPhysics >> defineGroupsOn: spec [
	spec group: 'model' with: #('BVC-Physics-Model' 'BVC-Physics-Collision').
	spec group: 'core' with: #(
		'model'
		'BVC-Physics-Pipeline'
		'BVC-Physics-Bloc'
		'BVC-Physics-Core'
		'BVC-Physics-Behaviours').
	spec group: 'runtime' with: #('core' 'BVC-Physics-Motion').
	spec group: 'tools' with: #('runtime' 'BVC-Physics-Tools').
	spec group: 'mondrian' with: #('tools' 'BVC-Physics-Mondrian').
	spec group: 'examples' with: #('mondrian' 'BVC-Physics-Examples').
	spec group: 'tests' with: #(
		'BVC-Physics-Tests-Core'
		'BVC-Physics-Tests-Behaviours'
		'BVC-Physics-Tests-Mondrian'
		'BVC-Physics-Tests-Tools').
	spec group: 'all' with: #('examples' 'tests').
	spec group: 'default' with: #('all')
]
