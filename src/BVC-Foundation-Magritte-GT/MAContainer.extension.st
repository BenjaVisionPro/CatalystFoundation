Extension { #name : 'MAContainer' }

{ #category : '*bvc-foundation-magritte-gt' }
MAContainer >> blocPresentationStencil [
	^ self
		propertyAt: #blocPresentationStencil
		ifAbsent: [ CFMaPresentationStencilBuilder new ]
]

{ #category : '*bvc-foundation-magritte-gt' }
MAContainer >> blocPresentationStencil: aStencilBuilder [
	"Stencil builder may be a block that receives the current memento and
	builds a fresh Magritte presentation for this form."
	self
		propertyAt: #blocPresentationStencil
		put: (aStencilBuilder asStencilBuilder: CFMaPresentationStencilBuilder)
]
