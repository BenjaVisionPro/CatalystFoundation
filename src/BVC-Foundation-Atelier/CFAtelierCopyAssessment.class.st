"I describe one assessed copy of an existing source object into a destination relation.

The source identity remains in its source relation. copiedObject is the already-materialized distinct identity that would be inserted. I retain both observed relation values and the complete proposed destination value so assessment remains descriptive and non-mutating."
Class {
	#name : 'CFAtelierCopyAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'sourceObject',
		'copiedObject',
		'sourceItems',
		'destinationItems',
		'proposedDestinationItems',
		'destinationIndex'
	],
	#category : 'BVC-Foundation-Atelier-Copy',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Copy'
}

{ #category : 'instance creation' }
CFAtelierCopyAssessment class >> sourceObject: aSourceObject copiedObject: aCopiedObject sourceItems: sourceCollection destinationItems: destinationCollection proposedDestinationItems: proposedCollection destinationIndex: anIndex [
	^ self new
		sourceObject: aSourceObject;
		copiedObject: aCopiedObject;
		sourceItems: sourceCollection;
		destinationItems: destinationCollection;
		proposedDestinationItems: proposedCollection;
		destinationIndex: anIndex;
		yourself
]

{ #category : 'instance creation' }
CFAtelierCopyAssessment class >> sourceObject: aSourceObject copiedObject: aCopiedObject sourceItems: sourceCollection destinationItems: destinationCollection rejectedBecause: aString [
	^ self new
		sourceObject: aSourceObject;
		copiedObject: aCopiedObject;
		sourceItems: sourceCollection;
		destinationItems: destinationCollection;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CFAtelierCopyAssessment >> sourceObject [ ^ sourceObject ]
{ #category : 'accessing' }
CFAtelierCopyAssessment >> sourceObject: anObject [ sourceObject := anObject ]
{ #category : 'accessing' }
CFAtelierCopyAssessment >> copiedObject [ ^ copiedObject ]
{ #category : 'accessing' }
CFAtelierCopyAssessment >> copiedObject: anObject [ copiedObject := anObject ]
{ #category : 'accessing' }
CFAtelierCopyAssessment >> sourceItems [ ^ sourceItems ]
{ #category : 'accessing' }
CFAtelierCopyAssessment >> sourceItems: aCollection [ sourceItems := aCollection ]
{ #category : 'accessing' }
CFAtelierCopyAssessment >> destinationItems [ ^ destinationItems ]
{ #category : 'accessing' }
CFAtelierCopyAssessment >> destinationItems: aCollection [ destinationItems := aCollection ]
{ #category : 'accessing' }
CFAtelierCopyAssessment >> proposedDestinationItems [ ^ proposedDestinationItems ]
{ #category : 'accessing' }
CFAtelierCopyAssessment >> proposedDestinationItems: aCollection [ proposedDestinationItems := aCollection ]
{ #category : 'accessing' }
CFAtelierCopyAssessment >> destinationIndex [ ^ destinationIndex ]
{ #category : 'accessing' }
CFAtelierCopyAssessment >> destinationIndex: anInteger [ destinationIndex := anInteger ]
