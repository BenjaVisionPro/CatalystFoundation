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

{ #category : 'examples - relations' }
CFMaPresentationExamples >> relationActivationCallbackCarriesEditingIdentity [
	<gtExample>
	| presentation object description memento element activated |
	presentation := CFMaPresentation new.
	object := Object new.
	description := MAToOneRelationDescription new.
	memento := CFMaMemento model: CFMaFormShowcase new.
	element := BlElement new.
	activated := nil.

	presentation relationActivateDo: [ :anObject :aDescription :aMemento :anElement |
		activated := { anObject. aDescription. aMemento. anElement } ].
	presentation
		activateRelationObject: object
		description: description
		memento: memento
		element: element.

	self assert: activated first == object.
	self assert: activated second == description.
	self assert: activated third == memento.
	self assert: activated fourth == element.
	^ presentation
]
