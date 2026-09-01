Extension { #name : 'MAToOneRelationDescription' }






{ #category : '*BVC-Foundation-Magritte-GT' }
MAToOneRelationDescription >> blocItemStencil [
	^ self
		propertyAt: #blocItemStencil
		ifAbsentPut: [
			[ :anItemViewModel :anIndex :aListElement |
				CFMaReferenceElementBuilder new
					object: anItemViewModel object;
					buildUsing: self reference ] asStencilBuilder: BrListRowStencilBuilder ]
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToOneRelationDescription >> blocItemStencil: aStencil [
	self
		propertyAt: #blocItemStencil
		put: (aStencil asStencilBuilder: BrListRowStencilBuilder)
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToOneRelationDescription >> blocItemViewModelStencil [
	^ self
		propertyAt: #blocItemViewModelStencil
		ifAbsent: [ GtMagritteModelStencilBuilder new ]
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToOneRelationDescription >> blocItemViewModelStencil: aStencil [
	self
		propertyAt: #blocItemViewModelStencil
		put: (aStencil asStencilBuilder: GtMagritteModelStencilBuilder)
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToOneRelationDescription >> newItemStencil [
	^ self propertyAt: #newItemStencil ifAbsent: [ nil ]
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToOneRelationDescription >> newItemStencil: aStencil [
	(aStencil isKindOf: BrStencil)
		ifTrue: [ ^ self propertyAt: #newItemStencil put: aStencil ].
	self
		propertyAt: #newItemStencil
		put: (aStencil asStencilBuilder: CFMaNewItemStencilBuilder)
]
