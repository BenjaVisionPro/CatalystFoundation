Class {
	#name : 'CFConfigurationPlacement',
	#superclass : 'Object',
	#instVars : [
		'description',
		'operationKind',
		'owner',
		'insertionIndex'
	],
	#category : 'BVC-Foundation-Config-Planner',
	#package : 'BVC-Foundation-Config-Planner'
}

{ #category : 'instance creation' }
CFConfigurationPlacement class >> owner: anOwner description: aDescription operationKind: aSymbol [
	^ self new
		owner: anOwner;
		description: aDescription;
		operationKind: aSymbol;
		yourself
]

{ #category : 'applying' }
CFConfigurationPlacement >> apply: aConfiguration to: aConfigurationOwner [
	| ownerDescription value |
	ownerDescription := self descriptionFor: aConfigurationOwner.
	self operationKind = #add
		ifTrue: [
			value := aConfigurationOwner readUsing: ownerDescription.
			aConfigurationOwner
				write: (self adding: aConfiguration to: value)
				using: ownerDescription ]
		ifFalse: [ aConfigurationOwner write: aConfiguration using: ownerDescription ].
	aConfiguration parent: aConfigurationOwner.
	^ aConfiguration
]


{ #category : 'private - applying' }
CFConfigurationPlacement >> adding: aConfiguration to: aCollection [
	| result |
	result := aCollection
		ifNil: [ OrderedCollection new ]
		ifNotNil: [ aCollection copy ].
	insertionIndex
		ifNil: [ result add: aConfiguration ]
		ifNotNil: [ result add: aConfiguration beforeIndex: insertionIndex ].
	^ result
]

{ #category : 'accessing' }
CFConfigurationPlacement >> description [
	^ description
]

{ #category : 'private - accessing' }
CFConfigurationPlacement >> descriptionFor: aConfigurationOwner [
	^ aConfigurationOwner magritteDescription
		detect: [ :each |
			each accessor readSelector = description accessor readSelector ]
		ifNone: [ self error: 'The placement description is not available on this configuration.' ]
]

{ #category : 'accessing' }
CFConfigurationPlacement >> description: anObject [
	description := anObject
]


{ #category : 'accessing' }
CFConfigurationPlacement >> insertionIndex [
	^ insertionIndex
]

{ #category : 'accessing' }
CFConfigurationPlacement >> insertionIndex: anInteger [
	insertionIndex := anInteger
]

{ #category : 'testing' }
CFConfigurationPlacement >> isAddition [
	^ operationKind = #add
]

{ #category : 'testing' }
CFConfigurationPlacement >> isReplacement [
	^ operationKind = #replace
]

{ #category : 'testing' }
CFConfigurationPlacement >> matches: anotherPlacement [
	^ owner == anotherPlacement owner
		and: [ operationKind = anotherPlacement operationKind
		and: [ description accessor readSelector
			= anotherPlacement description accessor readSelector ] ]
]

{ #category : 'accessing' }
CFConfigurationPlacement >> operationKind [
	^ operationKind
]

{ #category : 'accessing' }
CFConfigurationPlacement >> operationKind: anObject [
	operationKind := anObject
]

{ #category : 'accessing' }
CFConfigurationPlacement >> owner [
	^ owner
]

{ #category : 'accessing' }
CFConfigurationPlacement >> owner: anObject [
	owner := anObject
]
