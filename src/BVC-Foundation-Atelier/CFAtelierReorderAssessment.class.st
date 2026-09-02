"I describe one assessed reorder within an ordered to-many Magritte relation.

I retain the observed relation value, complete proposed replacement value and source/destination indices so a presentation can explain or preview the exact structural change without mutating editing state."
Class {
	#name : 'CFAtelierReorderAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'object',
		'items',
		'proposedItems',
		'sourceIndex',
		'destinationIndex'
	],
	#category : 'BVC-Foundation-Atelier-Reorder',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Reorder'
}

{ #category : 'instance creation' }
CFAtelierReorderAssessment class >> object: anObject items: aCollection proposedItems: proposedCollection sourceIndex: sourceIndex destinationIndex: destinationIndex [
	^ self new
		object: anObject;
		items: aCollection;
		proposedItems: proposedCollection;
		sourceIndex: sourceIndex;
		destinationIndex: destinationIndex;
		yourself
]

{ #category : 'instance creation' }
CFAtelierReorderAssessment class >> object: anObject items: aCollection rejectedBecause: aString [
	^ self new
		object: anObject;
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
CFAtelierReorderAssessment >> object [ ^ object ]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> object: anObject [ object := anObject ]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> proposedItems [ ^ proposedItems ]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> proposedItems: aCollection [ proposedItems := aCollection ]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> sourceIndex [ ^ sourceIndex ]
{ #category : 'accessing' }
CFAtelierReorderAssessment >> sourceIndex: anInteger [ sourceIndex := anInteger ]
