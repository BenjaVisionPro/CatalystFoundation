Class {
	#name : 'CFMyConfigurationGroupExample',
	#superclass : 'CFConfiguration',
	#instVars : [
		'configurations'
	],
	#category : 'BVC-Foundation-Config-Examples',
	#package : 'BVC-Foundation-Config-Examples'
}

{ #category : 'accessing' }
CFMyConfigurationGroupExample >> configurations [
	^ configurations
]

{ #category : 'accessing' }
CFMyConfigurationGroupExample >> configurations: aCollection [
	configurations := aCollection
]

{ #category : 'magritte' }
CFMyConfigurationGroupExample >> descriptionConfigurations [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #configurations;
		label: 'Configurations';
		priority: 20;
		classes: { CFMyConfigExample. CFMyConfigurationGroupExample };
		beOrdered;
		cfSerializable: true;
		yourself
]

{ #category : 'initialization' }
CFMyConfigurationGroupExample >> initialize [
	super initialize.
	configurations := OrderedCollection new
]
