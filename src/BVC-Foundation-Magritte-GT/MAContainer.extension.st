Extension { #name : 'MAContainer' }

{ #category : '*bvc-foundation-magritte-gt' }
MAContainer >> presentation [
	^ self
		propertyAt: #cfPresentationFactory
		ifPresent: [ :aFactory | aFactory value ]
		ifAbsent: [ CFMaPresentation new ]
]

{ #category : '*bvc-foundation-magritte-gt' }
MAContainer >> presentation: aFactory [
	self
		propertyAt: #cfPresentationFactory
		put: aFactory
]

{ #category : '*bvc-foundation-magritte-gt' }
MAContainer >> foundationPresentation [
	"Compatibility for the experimental Foundation Magritte code. New production descriptions use #presentation / #presentation:."
	^ self presentation
]

{ #category : '*bvc-foundation-magritte-gt' }
MAContainer >> foundationPresentation: aPresentationClass configure: aBlock [
	"Compatibility for the experimental Foundation Magritte code."
	self presentation: [ aPresentationClass configured: aBlock ]
]
