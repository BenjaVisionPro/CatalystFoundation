Class {
	#name : 'CFMyConfigurationHolderExample',
	#superclass : 'CFConfiguration',
	#instVars : [
		'configuration'
	],
	#category : 'BVC-Foundation-Config-Examples',
	#package : 'BVC-Foundation-Config-Examples'
}

{ #category : 'accessing' }
CFMyConfigurationHolderExample >> configuration [
	^ configuration
]

{ #category : 'accessing' }
CFMyConfigurationHolderExample >> configuration: aConfiguration [
	configuration := aConfiguration
]

{ #category : 'magritte' }
CFMyConfigurationHolderExample >> descriptionConfiguration [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #configuration;
		label: 'Configuration';
		priority: 20;
		classes: { CFMyConfigExample };
		cfSerializable: true;
		yourself
]
