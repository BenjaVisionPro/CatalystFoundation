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


{ #category : 'examples - canonical identity' }
CFMaIdentityAffordanceExamples >> objectIdentitySurface [
	<gtExample>
	| aMemento anElement |
	aMemento := CFMaMemento model: CFObject new.
	anElement := CFMaIdentityAffordanceElement new
		memento: aMemento;
		yourself.

	self assert: (aMemento magritteDescription
		select: [ :each | each cfCategory = #identity ]) size equals: 1.
	self assert: anElement iconContainer children size equals: 1.
	^ anElement
]

{ #category : 'examples - canonical identity' }
CFMaIdentityAffordanceExamples >> identifiableObjectIdentitySurface [
	<gtExample>
	| anObject aMemento anElement |
	anObject := CFIdentifiableObject new.
	aMemento := CFMaMemento model: anObject.
	anElement := CFMaIdentityAffordanceElement new
		memento: aMemento;
		yourself.

	self assert: (aMemento magritteDescription
		select: [ :each | each cfCategory = #identity ]) size equals: 2.
	self assert: anElement identifierElement visibility equals: BlVisibility visible.
	^ anElement
]

{ #category : 'examples - canonical identity' }
CFMaIdentityAffordanceExamples >> labelledObjectIdentitySurface [
	<gtExample>
	| anObject aMemento anElement |
	anObject := CFLabelledObject new
		label: 'Label';
		yourself.
	aMemento := CFMaMemento model: anObject.
	anElement := CFMaIdentityAffordanceElement new
		memento: aMemento;
		yourself.

	self assert: (aMemento magritteDescription
		select: [ :each | each cfCategory = #identity ]) size equals: 3.
	self assert: anElement labelElement visibility equals: BlVisibility visible.
	self assert: anElement identifierElement visibility equals: BlVisibility visible.
	^ anElement
]
