Class {
	#name : 'CFMaDetailPresentationExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-Detail-Examples',
	#package : 'BVC-Foundation-Magritte-Detail',
	#tag : 'Examples'
}

{ #category : 'examples' }
CFMaDetailPresentationExamples >> descriptionCategories [
	<gtExample>
	| aDescription |
	aDescription := MAStringDescription new
		categories: #(main extension);
		yourself.

	self assert: aDescription categories equals: #(main extension).
	^ aDescription
]

{ #category : 'examples' }
CFMaDetailPresentationExamples >> configuredPresentation [
	<gtExample>
	| aContainer aPresentation aGeneral aMain anExtension |
	aContainer := MAContainer new.
	aContainer blocPresentationStencil: [ :aMemento |
		CFMaDetailPresentation new
			group: 'General' configure: [ :general |
				general category: #main configure: [ :main |
					main asTabs.
					main category: #extension configure: [ :extension |
						extension asAccordions ] ] ];
			yourself ].

	aPresentation := aContainer blocPresentationStencil
		memento: nil;
		build.
	aGeneral := aPresentation groupConfigurationFor: 'General'.
	aMain := aGeneral categoryConfigurationFor: #main.
	anExtension := aMain categoryConfigurationFor: #extension.

	self assert: aMain arrangement isTabs.
	self assert: anExtension arrangement isAccordions.
	^ aPresentation
]

{ #category : 'examples' }
CFMaDetailPresentationExamples >> presentationStencilCreatesFreshInstances [
	<gtExample>
	| aContainer first second |
	aContainer := MAContainer new.
	aContainer blocPresentationStencil: [ :aMemento |
		CFMaDetailPresentation new
			group: 'General' configure: [ :general |
				general category: #main configure: [ :main | main asTabs ] ];
			yourself ].

	first := aContainer blocPresentationStencil
		memento: nil;
		build.
	second := aContainer blocPresentationStencil
		memento: nil;
		build.

	self assert: first ~~ second.
	self assert: (first groupConfigurationFor: 'General') ~~ (second groupConfigurationFor: 'General').
	^ first
]
