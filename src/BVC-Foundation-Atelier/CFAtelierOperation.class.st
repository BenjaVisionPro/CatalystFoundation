"I define the small shared lifecycle proven by Atelier operations.

An operation assesses current editing state without mutation. apply always performs a fresh assessment immediately before mutation and only delegates execution when that assessment is applicable.

I deliberately do not define source/target, placement, presentation, drag/drop, transaction, diagnostics or value-change abstractions. Concrete operations own their semantic inputs and assessment result types."
Class {
	#name : 'CFAtelierOperation',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Core',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Core'
}

{ #category : 'applying' }
CFAtelierOperation >> apply [
	| anAssessment |
	anAssessment := self assess.
	anAssessment isApplicable ifFalse: [ ^ anAssessment ].
	self applyAssessment: anAssessment.
	^ anAssessment
]

{ #category : 'applying' }
CFAtelierOperation >> applyAssessment: anAssessment [
	self subclassResponsibility
]

{ #category : 'assessing' }
CFAtelierOperation >> assess [
	self subclassResponsibility
]
