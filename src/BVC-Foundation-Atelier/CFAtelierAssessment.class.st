"I provide the minimal assessment protocol proven common across Atelier operations.

Concrete assessments retain whatever operation-specific observed and proposed state their presentations need. I only represent rejection text and derive applicability from its absence."
Class {
	#name : 'CFAtelierAssessment',
	#superclass : 'Object',
	#instVars : [
		'rejectionMessage'
	],
	#category : 'BVC-Foundation-Atelier-Core',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Core'
}

{ #category : 'testing' }
CFAtelierAssessment >> isApplicable [
	^ rejectionMessage isNil
]

{ #category : 'accessing' }
CFAtelierAssessment >> rejectionMessage [
	^ rejectionMessage
]

{ #category : 'accessing' }
CFAtelierAssessment >> rejectionMessage: aString [
	rejectionMessage := aString
]
