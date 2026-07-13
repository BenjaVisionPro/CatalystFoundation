Class {
	#name : 'CFConfigurationContext',
	#superclass : 'Object',
	#instVars : [
		'memento',
		'description',
		'operationKind',
		'insertionIndex'
	],
	#category : 'BVC-Foundation-Config-Core',
	#package : 'BVC-Foundation-Config-Core'
}

{ #category : 'instance creation' }
CFConfigurationContext class >> memento: aMemento description: aDescription operationKind: aSymbol insertionIndex: anInteger [
	^ self new
		memento: aMemento;
		description: aDescription;
		operationKind: aSymbol;
		insertionIndex: anInteger;
		yourself
]

{ #category : 'accessing' }
CFConfigurationContext >> description [ ^ description ]

{ #category : 'accessing' }
CFConfigurationContext >> description: anObject [ description := anObject ]

{ #category : 'accessing' }
CFConfigurationContext >> insertionIndex [ ^ insertionIndex ]

{ #category : 'accessing' }
CFConfigurationContext >> insertionIndex: anObject [ insertionIndex := anObject ]

{ #category : 'accessing' }
CFConfigurationContext >> memento [ ^ memento ]

{ #category : 'accessing' }
CFConfigurationContext >> memento: anObject [ memento := anObject ]

{ #category : 'accessing' }
CFConfigurationContext >> model [
	^ memento ifNil: [ nil ] ifNotNil: [ memento model ]
]

{ #category : 'accessing' }
CFConfigurationContext >> operationKind [ ^ operationKind ]

{ #category : 'accessing' }
CFConfigurationContext >> operationKind: anObject [ operationKind := anObject ]
