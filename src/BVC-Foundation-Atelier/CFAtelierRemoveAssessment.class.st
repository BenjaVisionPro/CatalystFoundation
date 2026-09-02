Class {
	#name : 'CFAtelierRemoveAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'object',
		'currentValue',
		'proposedValue'
	],
	#category : 'BVC-Foundation-Atelier-Removal',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Removal'
}

{ #category : 'instance creation' }
CFAtelierRemoveAssessment class >> object: anObject currentValue: aCurrentValue proposedValue: aProposedValue [
	^ self new
		object: anObject;
		currentValue: aCurrentValue;
		proposedValue: aProposedValue;
		yourself
]

{ #category : 'instance creation' }
CFAtelierRemoveAssessment class >> object: anObject currentValue: aCurrentValue rejectedBecause: aString [
	^ self new
		object: anObject;
		currentValue: aCurrentValue;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CFAtelierRemoveAssessment >> object [ ^ object ]
{ #category : 'accessing' }
CFAtelierRemoveAssessment >> object: anObject [ object := anObject ]
{ #category : 'accessing' }
CFAtelierRemoveAssessment >> currentValue [ ^ currentValue ]
{ #category : 'accessing' }
CFAtelierRemoveAssessment >> currentValue: aValue [ currentValue := aValue ]
{ #category : 'accessing' }
CFAtelierRemoveAssessment >> proposedValue [ ^ proposedValue ]
{ #category : 'accessing' }
CFAtelierRemoveAssessment >> proposedValue: aValue [ proposedValue := aValue ]
