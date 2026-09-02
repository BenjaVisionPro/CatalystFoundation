"I bundle the reusable orchestration choices for one Atelier editing context.

I do not configure Foundation presentation. Magritte descriptions and Foundation presentation configuration remain authoritative for rendering. I only carry Atelier-owned supply and operation translation choices so the same editing semantics can be reused when an Atelier changes root context."
Class {
	#name : 'CFAtelierConfiguration',
	#superclass : 'Object',
	#instVars : [
		'palette',
		'removeOperationBlock',
		'insertOperationBlock',
		'replaceOperationBlock',
		'moveOperationBlock'
	],
	#category : 'BVC-Foundation-Atelier-Configuration',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Configuration'
}

{ #category : 'applying' }
CFAtelierConfiguration >> applyEditingTo: anAtelierViewModel [
	removeOperationBlock ifNotNil: [ anAtelierViewModel removeOperationFor: removeOperationBlock ].
	insertOperationBlock ifNotNil: [ anAtelierViewModel insertOperationFor: insertOperationBlock ].
	replaceOperationBlock ifNotNil: [ anAtelierViewModel replaceOperationFor: replaceOperationBlock ].
	moveOperationBlock ifNotNil: [ anAtelierViewModel moveOperationFor: moveOperationBlock ].
	^ anAtelierViewModel
]

{ #category : 'applying' }
CFAtelierConfiguration >> applyTo: anAtelierViewModel [
	palette ifNotNil: [ anAtelierViewModel palette: palette ].
	^ self applyEditingTo: anAtelierViewModel
]

{ #category : 'accessing' }
CFAtelierConfiguration >> palette [
	^ palette
]

{ #category : 'accessing' }
CFAtelierConfiguration >> palette: anAtelierPalette [
	palette := anAtelierPalette
]

{ #category : 'configuration' }
CFAtelierConfiguration >> removeOperationFor: aBlock [
	removeOperationBlock := aBlock
]

{ #category : 'configuration' }
CFAtelierConfiguration >> insertOperationFor: aBlock [
	insertOperationBlock := aBlock
]

{ #category : 'configuration' }
CFAtelierConfiguration >> replaceOperationFor: aBlock [
	replaceOperationBlock := aBlock
]

{ #category : 'configuration' }
CFAtelierConfiguration >> moveOperationFor: aBlock [
	moveOperationBlock := aBlock
]
