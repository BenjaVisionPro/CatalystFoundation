"I describe one assessed insertion of an object into a to-many Magritte relation.

I retain the observed relation value and the complete proposed replacement value so a presentation can show exactly what would happen without mutating editing state."
Class {
	#name : 'CFAtelierInsertAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'object',
		'items',
		'proposedItems',
		'insertionIndex'
	],
	#category : 'BVC-Foundation-Atelier-Insertion',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Insertion'
}

{ #category : 'instance creation' }
CFAtelierInsertAssessment class >> object: anObject items: aCollection proposedItems: proposedCollection insertionIndex: anIndex [
	^ self new
		object: anObject;
		items: aCollection;
		proposedItems: proposedCollection;
		insertionIndex: anIndex;
		yourself
]

{ #category : 'instance creation' }
CFAtelierInsertAssessment class >> object: anObject items: aCollection rejectedBecause: aString [
	^ self new
		object: anObject;
		items: aCollection;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CFAtelierInsertAssessment >> insertionIndex [ ^ insertionIndex ]
{ #category : 'accessing' }
CFAtelierInsertAssessment >> insertionIndex: anInteger [ insertionIndex := anInteger ]
{ #category : 'accessing' }
CFAtelierInsertAssessment >> items [ ^ items ]
{ #category : 'accessing' }
CFAtelierInsertAssessment >> items: aCollection [ items := aCollection ]
{ #category : 'accessing' }
CFAtelierInsertAssessment >> object [ ^ object ]
{ #category : 'accessing' }
CFAtelierInsertAssessment >> object: anObject [ object := anObject ]
{ #category : 'accessing' }
CFAtelierInsertAssessment >> proposedItems [ ^ proposedItems ]
{ #category : 'accessing' }
CFAtelierInsertAssessment >> proposedItems: aCollection [ proposedItems := aCollection ]
