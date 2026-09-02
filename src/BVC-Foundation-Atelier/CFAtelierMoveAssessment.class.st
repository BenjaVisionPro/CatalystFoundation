"I describe the result of assessing one CFAtelierMove against the current Magritte editing state.

I am deliberately move-specific. I retain the observed and proposed relation values so a presentation can explain or preview the exact move that was assessed. I do not mutate editing state."
Class {
	#name : 'CFAtelierMoveAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'sourceItems',
		'destinationItems',
		'proposedSourceItems',
		'proposedDestinationItems'
	],
	#category : 'BVC-Foundation-Atelier-Move',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Move'
}

{ #category : 'instance creation' }
CFAtelierMoveAssessment class >> sourceItems: sourceItems destinationItems: destinationItems proposedSourceItems: proposedSourceItems proposedDestinationItems: proposedDestinationItems [
	^ self new
		sourceItems: sourceItems;
		destinationItems: destinationItems;
		proposedSourceItems: proposedSourceItems;
		proposedDestinationItems: proposedDestinationItems;
		yourself
]

{ #category : 'instance creation' }
CFAtelierMoveAssessment class >> sourceItems: sourceItems destinationItems: destinationItems rejectedBecause: aString [
	^ self new
		sourceItems: sourceItems;
		destinationItems: destinationItems;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CFAtelierMoveAssessment >> destinationItems [
	^ destinationItems
]

{ #category : 'accessing' }
CFAtelierMoveAssessment >> destinationItems: aCollection [
	destinationItems := aCollection
]

{ #category : 'accessing' }
CFAtelierMoveAssessment >> proposedDestinationItems [
	^ proposedDestinationItems
]

{ #category : 'accessing' }
CFAtelierMoveAssessment >> proposedDestinationItems: aCollection [
	proposedDestinationItems := aCollection
]

{ #category : 'accessing' }
CFAtelierMoveAssessment >> proposedSourceItems [
	^ proposedSourceItems
]

{ #category : 'accessing' }
CFAtelierMoveAssessment >> proposedSourceItems: aCollection [
	proposedSourceItems := aCollection
]

{ #category : 'accessing' }
CFAtelierMoveAssessment >> sourceItems [
	^ sourceItems
]

{ #category : 'accessing' }
CFAtelierMoveAssessment >> sourceItems: aCollection [
	sourceItems := aCollection
]
