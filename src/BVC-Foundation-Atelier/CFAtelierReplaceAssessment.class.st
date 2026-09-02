"I describe one assessed replacement in a Magritte relation.

I retain the old and replacement object identities, the complete observed/proposed relation values, and the replacement index when the relation is ordered. A presentation can therefore preview the exact structural substitution without owning operation semantics."
Class {
	#name : 'CFAtelierReplaceAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'object',
		'replacementObject',
		'currentValue',
		'proposedValue',
		'replacementIndex'
	],
	#category : 'BVC-Foundation-Atelier-Replacement',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Replacement'
}

{ #category : 'instance creation' }
CFAtelierReplaceAssessment class >> object: anObject replacementObject: replacementObject currentValue: currentValue proposedValue: proposedValue replacementIndex: replacementIndex [
	^ self new
		object: anObject;
		replacementObject: replacementObject;
		currentValue: currentValue;
		proposedValue: proposedValue;
		replacementIndex: replacementIndex;
		yourself
]

{ #category : 'instance creation' }
CFAtelierReplaceAssessment class >> object: anObject replacementObject: replacementObject currentValue: currentValue rejectedBecause: aString [
	^ self new
		object: anObject;
		replacementObject: replacementObject;
		currentValue: currentValue;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CFAtelierReplaceAssessment >> currentValue [ ^ currentValue ]
{ #category : 'accessing' }
CFAtelierReplaceAssessment >> currentValue: anObject [ currentValue := anObject ]
{ #category : 'accessing' }
CFAtelierReplaceAssessment >> object [ ^ object ]
{ #category : 'accessing' }
CFAtelierReplaceAssessment >> object: anObject [ object := anObject ]
{ #category : 'accessing' }
CFAtelierReplaceAssessment >> proposedValue [ ^ proposedValue ]
{ #category : 'accessing' }
CFAtelierReplaceAssessment >> proposedValue: anObject [ proposedValue := anObject ]
{ #category : 'accessing' }
CFAtelierReplaceAssessment >> replacementIndex [ ^ replacementIndex ]
{ #category : 'accessing' }
CFAtelierReplaceAssessment >> replacementIndex: anInteger [ replacementIndex := anInteger ]
{ #category : 'accessing' }
CFAtelierReplaceAssessment >> replacementObject [ ^ replacementObject ]
{ #category : 'accessing' }
CFAtelierReplaceAssessment >> replacementObject: anObject [ replacementObject := anObject ]
