"I provide executable examples for Foundation Magritte presentations."

Class {
	#name : 'CFMaPresentationExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Examples'
}

{ #category : 'examples - presentations' }
CFMaPresentationExamples >> defaultPresentation [
	<gtExample>
	^ CFMaPresentation new
]

{ #category : 'examples - presentations' }
CFMaPresentationExamples >> accordionPresentation [
	<gtExample>
	^ CFMaAccordionPresentation new
]

{ #category : 'examples - presentations' }
CFMaPresentationExamples >> tabbedPresentation [
	<gtExample>
	^ CFMaTabbedPresentation new
]

{ #category : 'examples - presentations' }
CFMaPresentationExamples >> settingsPresentation [
	<gtExample>
	^ CFMaSettingsPresentation new
]

{ #category : 'examples - presentations' }
CFMaPresentationExamples >> leftTabbedPresentation [
	<gtExample>
	^ CFMaLeftTabbedPresentation new
]

{ #category : 'examples - forms' }
CFMaPresentationExamples >> accordionPresentationElement [
	<gtExample>
	| aViewModel |
	aViewModel := CFMaViewModel forObject: CFMaFormShowcase example.
	aViewModel presentationClass: CFMaAccordionPresentation.
	^ aViewModel asElement
]

{ #category : 'examples - forms' }
CFMaPresentationExamples >> tabbedPresentationElement [
	<gtExample>
	| aViewModel |
	aViewModel := CFMaViewModel forObject: CFMaFormShowcase example.
	aViewModel presentationClass: CFMaTabbedPresentation.
	^ aViewModel asElement
]

{ #category : 'examples - forms' }
CFMaPresentationExamples >> settingsPresentationElement [
	<gtExample>
	| aViewModel |
	aViewModel := CFMaViewModel forObject: CFMaFormShowcase example.
	aViewModel presentationClass: CFMaSettingsPresentation.
	^ aViewModel asElement
]

{ #category : 'examples - forms' }
CFMaPresentationExamples >> leftTabbedPresentationElement [
	<gtExample>
	| aViewModel |
	aViewModel := CFMaViewModel forObject: CFMaFormShowcase example.
	aViewModel presentationClass: CFMaLeftTabbedPresentation.
	^ aViewModel asElement
]

{ #category : 'examples - forms' }
CFMaPresentationExamples >> showcaseUsesSettingsPresentation [
	<gtExample>
	| aViewModel |
	aViewModel := CFMaFormShowcase example asGtMagritteViewModel.

	self assert: aViewModel presentationClass equals: CFMaSettingsPresentation.
	^ aViewModel asElement
]

{ #category : 'examples - paths' }
CFMaPresentationExamples >> descriptionPath [
	<gtExample>
	| aDescription |
	aDescription := MAStringDescription new.
	self assert: aDescription path equals: #().
	aDescription path: #(appearance display).
	self assert: aDescription path equals: #(appearance display).
	self assert: (aDescription propertyAt: #cfPath) equals: #(appearance display).
	^ aDescription
]

{ #category : 'examples - paths' }
CFMaPresentationExamples >> showcasePathsAreScopedToFields [
	<gtExample>
	| aShowcase descriptions fieldDescriptions relationDescriptions |
	aShowcase := CFMaFormShowcase example.
	descriptions := aShowcase magritteDescription children.
	fieldDescriptions := descriptions select: [ :each | each group = 'Fields' ].
	relationDescriptions := descriptions reject: [ :each | each group = 'Fields' ].

	self assert: fieldDescriptions isNotEmpty.
	self assert: (fieldDescriptions allSatisfy: [ :each | each path isNotEmpty ]).
	self assert: (relationDescriptions allSatisfy: [ :each | each path isEmpty ]).
	^ aShowcase
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsRowAptitude [
	<gtExample>
	| anAptitude |
	anAptitude := CFMaSettingsRowAptitude new.
	self assert: anAptitude class equals: CFMaSettingsRowAptitude.
	^ anAptitude
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsEditorAptitude [
	<gtExample>
	| anAptitude |
	anAptitude := CFMaSettingsEditorAptitude new.
	self assert: anAptitude class equals: CFMaSettingsEditorAptitude.
	^ anAptitude
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsFocusOverlayUsesBlocOverlay [
	<gtExample>
	| aRow anOverlay aContainer |
	aContainer := BrFrame new
		hExact: 200;
		vExact: 40;
		yourself.
	aRow := BrFrame new
		hExact: 200;
		vExact: 40;
		yourself.
	aContainer addChild: aRow.
	anOverlay := BlOverlayElement on: aRow.
	aContainer addChild: anOverlay.

	self assert: anOverlay isAttached.
	self assert: anOverlay parent equals: aContainer.
	^ anOverlay
]
