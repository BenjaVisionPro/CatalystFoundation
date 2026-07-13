Class {
	#name : 'CFConfigurationPlacement',
	#superclass : 'Object',
	#instVars : [
		'memento',
		'description',
		'operationKind',
		'insertionIndex'
	],
	#category : 'BVC-Foundation-Config-Planner',
	#package : 'BVC-Foundation-Config-Planner'
}

{ #category : 'instance creation' }
CFConfigurationPlacement class >> memento: aMemento description: aDescription operationKind: aSymbol [
	^ self new
		memento: aMemento;
		description: aDescription;
		operationKind: aSymbol;
		yourself
]

{ #category : 'applying' }
CFConfigurationPlacement >> apply: anObject [
	| oldValue newValue |
	oldValue := memento readUsing: description.
	newValue := self isAddition
		ifTrue: [ self adding: anObject to: oldValue ]
		ifFalse: [ anObject ].
	memento write: newValue using: description.
	(self isReplacement and: [ oldValue notNil and: [ oldValue ~~ anObject ] ]) ifTrue: [
		(oldValue respondsTo: #removeFromRelationInContext:)
			ifTrue: [ oldValue removeFromRelationInContext: self removalContext ] ].
	(anObject respondsTo: #addToRelationInContext:)
		ifTrue: [ anObject addToRelationInContext: self relationContext ].
	^ anObject
]

{ #category : 'private - applying' }
CFConfigurationPlacement >> adding: anObject to: aCollection [
	| result collectionClass |
	collectionClass := description kind ifNil: [ OrderedCollection ].
	result := aCollection
		ifNil: [ collectionClass new ]
		ifNotNil: [ aCollection copy ].
	insertionIndex
		ifNil: [ result add: anObject ]
		ifNotNil: [ result add: anObject beforeIndex: insertionIndex ].
	^ result
]

{ #category : 'accessing' }
CFConfigurationPlacement >> description [ ^ description ]

{ #category : 'accessing' }
CFConfigurationPlacement >> description: anObject [ description := anObject ]

{ #category : 'initialization' }
CFConfigurationPlacement >> initializeObject: anObject [
	anObject initializeInContext: self relationContext
]

{ #category : 'accessing' }
CFConfigurationPlacement >> insertionIndex [ ^ insertionIndex ]

{ #category : 'accessing' }
CFConfigurationPlacement >> insertionIndex: anInteger [ insertionIndex := anInteger ]

{ #category : 'testing' }
CFConfigurationPlacement >> isAddition [ ^ operationKind = #add ]

{ #category : 'testing' }
CFConfigurationPlacement >> isReplacement [ ^ operationKind = #replace ]

{ #category : 'testing' }
CFConfigurationPlacement >> matches: anotherPlacement [
	^ memento model == anotherPlacement memento model
		and: [ description = anotherPlacement description
		and: [ operationKind = anotherPlacement operationKind ] ]
]

{ #category : 'accessing' }
CFConfigurationPlacement >> memento [ ^ memento ]

{ #category : 'accessing' }
CFConfigurationPlacement >> memento: anObject [ memento := anObject ]

{ #category : 'accessing' }
CFConfigurationPlacement >> operationKind [ ^ operationKind ]

{ #category : 'accessing' }
CFConfigurationPlacement >> operationKind: anObject [ operationKind := anObject ]

{ #category : 'accessing' }
CFConfigurationPlacement >> removalContext [
	^ CFConfigurationContext
		memento: memento
		description: description
		operationKind: #remove
		insertionIndex: insertionIndex
]

{ #category : 'accessing' }
CFConfigurationPlacement >> relationContext [
	^ CFConfigurationContext
		memento: memento
		description: description
		operationKind: operationKind
		insertionIndex: insertionIndex
]
