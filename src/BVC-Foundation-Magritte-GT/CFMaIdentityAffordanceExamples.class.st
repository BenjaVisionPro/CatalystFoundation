"I provide executable examples for Foundation's compact editable identity affordance."

Class {
	#name : 'CFMaIdentityAffordanceExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Examples'
}

{ #category : 'examples' }
CFMaIdentityAffordanceExamples >> identityAffordance [
	<gtExample>
	| anObject aMemento anElement |
	anObject := CFMaFormShowcaseItem exampleNamed: 'Label' score: 30 status: #active.
	aMemento := CFMaMemento model: anObject.
	anElement := CFMaIdentityAffordanceStencil new
		memento: aMemento;
		create.

	self assert: anElement class equals: CFMaIdentityAffordanceElement.
	self assert: anElement constraints vertical resizer isExact.
	self assert: anElement labelElement text asString equals: 'Label'.
	self assert: anElement identifierElement text asString equals: anObject identifier asString.
	^ anElement
]

{ #category : 'examples' }
CFMaIdentityAffordanceExamples >> labelEditUsesMemento [
	<gtExample>
	| anObject aMemento anElement aDescription |
	anObject := CFMaFormShowcaseItem exampleNamed: 'Label' score: 30 status: #active.
	aMemento := CFMaMemento model: anObject.
	anElement := CFMaIdentityAffordanceStencil new
		memento: aMemento;
		create.
	aDescription := aMemento magritteDescription
		detect: [ :each | each handlesSelector: #label ].

	aMemento write: 'Edited label' using: aDescription.
	anElement labelElement text: 'Edited label'.

	self assert: anObject label equals: 'Label'.
	self assert: aMemento overallStatus valueOrNil isChanged.
	^ anElement
]
