Class {
	#name : 'CFConfiguration',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'parent'
	],
	#category : 'BVC-Foundation-Config-Core',
	#package : 'BVC-Foundation-Config-Core'
}

{ #category : 'instance creation' }
CFConfiguration class >> defaultWithParent: aConfiguration [
	^ self new
		parent: aConfiguration;
		yourself
]

{ #category : 'accessing' }
CFConfiguration >> ancestorConfigurations [
	| ancestors configuration |
	ancestors := OrderedCollection new.
	configuration := parent.
	[ configuration notNil ] whileTrue: [
		ancestors add: configuration.
		configuration := configuration parent ].
	^ ancestors
]

{ #category : 'testing' }
CFConfiguration >> hasParent [
	^ parent notNil
]

{ #category : 'initialization' }
CFConfiguration >> initialize [
	super initialize.
	self label: ''
]

{ #category : 'accessing' }
CFConfiguration >> parent [
	^ parent
]

{ #category : 'accessing' }
CFConfiguration >> parent: aConfiguration [
	parent := aConfiguration
]

{ #category : 'accessing' }
CFConfiguration >> rootConfiguration [
	| configuration |
	configuration := self.
	[ configuration parent notNil ] whileTrue: [ configuration := configuration parent ].
	^ configuration
]

{ #category : 'validation' }
CFConfiguration >> validateConfigurationGraphOn: aValidationResult [
	^ aValidationResult
]


{ #category : 'configuration lifecycle' }
CFConfiguration >> addToRelationInContext: aContext [
	self parent: aContext model
]

{ #category : 'configuration lifecycle' }
CFConfiguration >> removeFromRelationInContext: aContext [
	self parent == aContext model ifTrue: [ self parent: nil ]
]
