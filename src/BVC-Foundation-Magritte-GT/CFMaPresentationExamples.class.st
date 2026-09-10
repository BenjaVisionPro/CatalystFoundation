"
I provide executable examples for Foundation Magritte form-level presentation contracts.
"
Class {
	#name : 'CFMaPresentationExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Examples'
}

{ #category : 'examples - focus' }
CFMaPresentationExamples >> fieldConfigurationInstallsFormNavigation [
	<gtExample>
	| aPresentation aField aDescription |
	aPresentation := CFMaPresentation new.
	aField := BlElement new.
	aDescription := MAStringDescription new.

	aPresentation configureTabStopFor: aField using: aDescription.

	self assert: aField focusability equals: BlFocusability after.
	self assert: (aField userData at: #cfMaFormNavigation).
	aPresentation installFormNavigationOn: aField.
	self assert: (aField userData at: #cfMaFormNavigation).
	^ aField
]

{ #category : 'examples - focus' }
CFMaPresentationExamples >> navigationUsesOutermostFoundationFormRoot [
	<gtExample>
	| aPresentation anOuterRoot anInnerRoot aField |
	aPresentation := CFMaPresentation new.
	anOuterRoot := CFMaFormRootElement new.
	anInnerRoot := CFMaFormRootElement new.
	aField := BlElement new.

	anOuterRoot addChild: anInnerRoot.
	anInnerRoot addChild: aField.
	aPresentation form: anOuterRoot.

	self assert: (aPresentation navigationRootFor: aField) == anOuterRoot.
	^ anOuterRoot
]


{ #category : 'examples - transactions' }
CFMaPresentationExamples >> transactionMementoOverridesActionMemento [
	<gtExample>
	| modelMemento transactionMemento presentation |
	modelMemento := CFMaMemento model: CFMaFormShowcase new.
	transactionMemento := CFMaMemento model: CFMaFormShowcase new.
	presentation := CFMaPresentation new
		memento: modelMemento;
		transactionMemento: transactionMemento;
		yourself.

	self assert: presentation memento == modelMemento.
	self assert: presentation actionMemento == transactionMemento.
	^ presentation
]
