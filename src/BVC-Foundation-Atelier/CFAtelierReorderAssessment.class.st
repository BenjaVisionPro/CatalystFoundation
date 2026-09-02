"I describe one assessed reorder of one or more identities within an ordered to-many Magritte relation.

I retain the observed relation value, complete proposed replacement value and source/destination indices so a presentation can explain or preview the exact structural change without mutating editing state. destinationIndex is the first index occupied by the moved group in the final collection."
Class {
	#name : 'CFAtelierReorderAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'objects',
		'items',
		'proposedItems',
		'sourceIndices',
		'destinationIndex'
	],
	#category : 'BVC-Foundation-Atelier-Reorder',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Reorder'
}

{ #category : 'instance creation' }
CFAtelierReorderAssessment class >> object: anObject items: aCollection proposedItems: proposedCollection sourceIndex: sourceIndex destinationIndex: destinationIndex [
	^ self
		objects: { anObject }
		items: aCollection
		proposedItems: proposedCollection
		sourceIndices: { sourceIndex }
		destinationIndex: destinationIndex
]

{ #category : 'instance creation' }
CFAtelierReorderAssessment class >> object: anObject items: aCollection rejectedBecause: aString [
	^ self
		objects: { anObject }
		items: aCollection
		rejectedBecause: aString
]

{ #category : 'instance creation' }
CFAtelierReorderAssessment class >> objects: someObjects items: aCollection proposedItems: proposedCollection sourceIndices: someIndices destinationIndex: destinationIndex [
	^ self new
		objects: someObjects;
		items: aCollection;
		proposedItems: proposedCollection;
		sourceIndices: someIndices;
		destinationIndex: destinationIndex;
		yourself
]

{ #category : 'instance creation' }
CFAtelierReorderAssessment class >> objects: someObjects items: aCollection rejectedBecause: aString [
	^ self new
		objects: someObjects;
		items: aCollection;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CFAtelierReorderAssessment >> destinationIndex [ ^ destinationIndex ]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> destinationIndex: anInteger [ destinationIndex := anInteger ]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> items [ ^ items ]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> items: aCollection [ items := aCollection ]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> object [
	^ objects ifNotNil: [ objects size = 1 ifTrue: [ objects first ] ]
]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> object: anObject [ objects := { anObject } ]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> objects [ ^ objects ]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> objects: someObjects [ objects := someObjects ]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> proposedItems [ ^ proposedItems ]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> proposedItems: aCollection [ proposedItems := aCollection ]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> sourceIndex [
	^ sourceIndices ifNotNil: [ sourceIndices size = 1 ifTrue: [ sourceIndices first ] ]
]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> sourceIndex: anInteger [ sourceIndices := { anInteger } ]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> sourceIndices [ ^ sourceIndices ]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> sourceIndices: someIndices [ sourceIndices := someIndices ]
