Class {
	#name : 'CFAtelierRemoveAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'objects',
		'currentValue',
		'proposedValue'
	],
	#category : 'BVC-Foundation-Atelier-Removal',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Removal'
}

{ #category : 'instance creation' }
CFAtelierRemoveAssessment class >> object: anObject currentValue: aCurrentValue proposedValue: aProposedValue [
	^ self
		objects: { anObject }
		currentValue: aCurrentValue
		proposedValue: aProposedValue
]

{ #category : 'instance creation' }
CFAtelierRemoveAssessment class >> object: anObject currentValue: aCurrentValue rejectedBecause: aString [
	^ self
		objects: { anObject }
		currentValue: aCurrentValue
		rejectedBecause: aString
]

{ #category : 'instance creation' }
CFAtelierRemoveAssessment class >> objects: someObjects currentValue: aCurrentValue proposedValue: aProposedValue [
	^ self new
		objects: someObjects;
		currentValue: aCurrentValue;
		proposedValue: aProposedValue;
		yourself
]

{ #category : 'instance creation' }
CFAtelierRemoveAssessment class >> objects: someObjects currentValue: aCurrentValue rejectedBecause: aString [
	^ self new
		objects: someObjects;
		currentValue: aCurrentValue;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CFAtelierRemoveAssessment >> object [
	^ objects ifEmpty: [ nil ] ifNotEmpty: [ objects first ]
]

{ #category : 'accessing' }
CFAtelierRemoveAssessment >> object: anObject [ objects := { anObject } ]
{ #category : 'accessing' }
CFAtelierRemoveAssessment >> objects [ ^ objects ]
{ #category : 'accessing' }
CFAtelierRemoveAssessment >> objects: someObjects [ objects := someObjects asArray ]
{ #category : 'accessing' }
CFAtelierRemoveAssessment >> currentValue [ ^ currentValue ]
{ #category : 'accessing' }
CFAtelierRemoveAssessment >> currentValue: aValue [ currentValue := aValue ]
{ #category : 'accessing' }
CFAtelierRemoveAssessment >> proposedValue [ ^ proposedValue ]
{ #category : 'accessing' }
CFAtelierRemoveAssessment >> proposedValue: aValue [ proposedValue := aValue ]
