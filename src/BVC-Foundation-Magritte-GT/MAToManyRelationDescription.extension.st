Extension { #name : 'MAToManyRelationDescription' }

{ #category : '*bvc-foundation-magritte-gt' }
MAToManyRelationDescription >> beAccordionList [
	self
		blocItemViewModelStencil: CFMaExpanderItemViewModelStencilBuilder new;
		blocListStencil: CFMaAccordionListElementStencilBuilder new
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToManyRelationDescription >> beColumnedList [
	self
		blocItemViewModelStencil: GtMagritteModelStencilBuilder new;
		blocListStencil: CFMaColumnedListElementStencilBuilder new
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToManyRelationDescription >> beExpandableList [
	self
		blocItemViewModelStencil: CFMaExpanderItemViewModelStencilBuilder new;
		blocListStencil: CFMaExpandableListElementStencilBuilder new
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToManyRelationDescription >> beGrid [
	self
		blocItemViewModelStencil: GtMagritteModelStencilBuilder new;
		blocListStencil: CFMaGridElementStencilBuilder new
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToManyRelationDescription >> beSimpleList [
	self
		blocItemViewModelStencil: GtMagritteModelStencilBuilder new;
		blocListStencil: CFMaListElementStencilBuilder new
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToManyRelationDescription >> blocItemStencil [
	^ self
		propertyAt: #blocItemStencil
		ifAbsentPut: [ [ :anItemViewModel :anIndex :aListElement |
			CFCompactObjectStencil new
				object: anItemViewModel object;
				create ] asStencilBuilder: BrListRowStencilBuilder ]
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToManyRelationDescription >> blocItemStencil: aStencil [
	self
		propertyAt: #blocItemStencil
		put: (aStencil asStencilBuilder: BrListRowStencilBuilder)
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToManyRelationDescription >> blocListStencil [
	^ self
		propertyAt: #blocListStencil
		ifAbsent: [ CFMaListElementStencilBuilder new ]
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToManyRelationDescription >> blocListStencil: aStencil [
	self
		propertyAt: #blocListStencil
		put: (aStencil asStencilBuilder: GtMagritteListElementStencilBuilder)
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToManyRelationDescription >> newItemStencil [
	^ self propertyAt: #newItemStencil ifAbsent: [ nil ]
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToManyRelationDescription >> newItemStencil: aStencil [
	aStencil ifNil: [
		^ self propertyAt: #newItemStencil put: nil ].
	(aStencil isKindOf: BrStencil)
		ifTrue: [ ^ self propertyAt: #newItemStencil put: aStencil ].
	self
		propertyAt: #newItemStencil
		put: (aStencil asStencilBuilder: CFMaNewItemStencilBuilder)
]
