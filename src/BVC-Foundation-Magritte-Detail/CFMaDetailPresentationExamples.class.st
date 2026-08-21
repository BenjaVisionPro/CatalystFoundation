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
	aContainer presentation: [
		CFMaDetailPresentation configured: [ :detail |
			detail group: 'General' configure: [ :general |
				general category: #main configure: [ :main |
					main asTabs.
					main category: #extension configure: [ :extension |
						extension asAccordions ] ] ] ] ].

	aPresentation := aContainer presentation.
	aGeneral := aPresentation groupConfigurationFor: 'General'.
	aMain := aGeneral categoryConfigurationFor: #main.
	anExtension := aMain categoryConfigurationFor: #extension.

	self assert: aMain arrangement isTabs.
	self assert: anExtension arrangement isAccordions.
	^ aPresentation
]

{ #category : 'examples' }
CFMaDetailPresentationExamples >> presentationFactoryCreatesFreshInstances [
	<gtExample>
	| aContainer first second |
	aContainer := MAContainer new
		presentation: [
			CFMaDetailPresentation configured: [ :detail |
				detail group: 'General' configure: [ :general |
					general category: #main configure: [ :main | main asTabs ] ] ] ];
		yourself.

	first := aContainer presentation.
	second := aContainer presentation.

	self assert: first ~~ second.
	self assert: (first groupConfigurationFor: 'General') ~~ (second groupConfigurationFor: 'General').
	^ first
]
