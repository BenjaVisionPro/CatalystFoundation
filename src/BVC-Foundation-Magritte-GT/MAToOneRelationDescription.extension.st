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
MAToOneRelationDescription >> beCompactList [
	self blocStencil: CFMaToOneElementStencilBuilder new
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToOneRelationDescription >> beColumnedList [
	self blocStencil: CFMaColumnedToOneElementStencilBuilder new
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToOneRelationDescription >> blocItemViewModelStencil [
	^ self
		propertyAt: #blocItemViewModelStencil
		ifAbsent: [ GtMagritteModelStencilBuilder new ]
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToOneRelationDescription >> blocItemViewModelStencil: aStencil [
	self
		propertyAt: #blocItemViewModelStencil
		put: (aStencil asStencilBuilder: GtMagritteModelStencilBuilder)
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToOneRelationDescription >> blocItemStencil [
	^ self
		propertyAt: #blocItemStencil
		ifAbsentPut: [
			[ :anItemViewModel :anIndex :aListElement |
				CFCompactObjectStencil new
					object: anItemViewModel object;
					create ] asStencilBuilder: BrListRowStencilBuilder ]
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToOneRelationDescription >> blocItemStencil: aStencil [
	self
		propertyAt: #blocItemStencil
		put: (aStencil asStencilBuilder: BrListRowStencilBuilder)
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
