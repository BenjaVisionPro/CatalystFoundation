Extension { #name : 'MAToOneRelationDescription' }

{ #category : '*bvc-foundation-magritte-gt' }
MAToOneRelationDescription >> beEmbeddedForm [
	self blocStencil: CFMaToOneEmbeddedFormStencilBuilder new
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToOneRelationDescription >> bePhlowLink [
	self blocStencil: CFMaToOnePhlowLinkStencilBuilder new
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToOneRelationDescription >> newItemStencil [
	| theClasses |
	^ self
		propertyAt: #newItemStencil
		ifAbsent: [
			theClasses := self classes ifNil: [ #() ].
			theClasses isEmpty
				ifTrue: [ nil ]
				ifFalse: [ [ :aClass | aClass new ] asStencilBuilder: CFMaNewItemStencilBuilder ] ]
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToOneRelationDescription >> newItemStencil: aStencil [
	(aStencil isKindOf: BrStencil)
		ifTrue: [ ^ self propertyAt: #newItemStencil put: aStencil ].
	self
		propertyAt: #newItemStencil
		put: (aStencil asStencilBuilder: CFMaNewItemStencilBuilder)
]
