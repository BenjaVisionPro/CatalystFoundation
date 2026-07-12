Class {
	#name : 'CFMyConfigExample',
	#superclass : 'CFConfiguration',
	#instVars : [
		'endpoint'
	],
	#category : 'BVC-Foundation-Config-Examples',
	#package : 'BVC-Foundation-Config-Examples'
}

{ #category : 'magritte' }
CFMyConfigExample >> descriptionEndpoint [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #endpoint;
		label: 'Endpoint';
		priority: 20;
		beRequired;
		yourself
]

{ #category : 'accessing' }
CFMyConfigExample >> endpoint [
	^ endpoint
]

{ #category : 'accessing' }
CFMyConfigExample >> endpoint: aString [
	endpoint := aString
]
