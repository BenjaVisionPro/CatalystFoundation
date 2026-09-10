Class {
	#name : 'CFIdentifiableObjectExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Core-Examples',
	#package : 'BVC-Foundation-Core'
}

{ #category : 'examples' }
CFIdentifiableObjectExamples >> generatedIdentifier [
	<gtExample>
	| object |
	object := CFIdentifiableObject new.
	self assert: object identifier isNotNil.
	^ object
]

{ #category : 'examples' }
CFIdentifiableObjectExamples >> suppliedIdentifierSurvivesInitialization [
	<gtExample>
	| object |
	object := CFIdentifiableObject identifier: #Task_customerApproval.
	self assert: object identifier equals: #Task_customerApproval.
	^ object
]
