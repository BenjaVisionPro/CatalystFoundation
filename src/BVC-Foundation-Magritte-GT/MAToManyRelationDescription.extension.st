Extension { #name : 'MAToManyRelationDescription' }



{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> itemsAsIdentityAffordances [
	self
		blocItemViewModelStencil: CFMaIdentityItemViewModelStencilBuilder new;
		blocItemStencil: CFMaIdentityAffordanceItemStencilBuilder new
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> itemsAsCompactObjects [
	self
		blocItemViewModelStencil: GtMagritteModelStencilBuilder new;
		blocItemStencil: ([ :anItemViewModel :anIndex :aListElement |
			CFCompactObjectStencil new
				object: anItemViewModel object;
				create ] asStencilBuilder: BrListRowStencilBuilder)
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> itemsAsEmbeddedForms [
	(self blocListStencil isKindOf: CFMaListElementStencilBuilder)
		ifTrue: [ self blocListStencil: CFMaFiniteListElementStencilBuilder new ].

	self
		blocItemViewModelStencil: CFMaEmbeddedItemViewModelStencilBuilder new;
		blocItemStencil: CFMaEmbeddedFormItemStencilBuilder new;
		relationBodyInsets: BlInsets empty;
		relationGridItemInsets: BlInsets empty
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> itemsAsPhlowLinks [
	self
		blocItemViewModelStencil: GtMagritteModelStencilBuilder new;
		blocItemStencil: CFMaPhlowLinkItemStencilBuilder new
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> beAccordionList [
	self
		blocItemViewModelStencil: CFMaExpanderItemViewModelStencilBuilder new;
		blocListStencil: CFMaAccordionListElementStencilBuilder new
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> beColumnedList [
	self
		blocItemViewModelStencil: GtMagritteModelStencilBuilder new;
		blocListStencil: CFMaColumnedListElementStencilBuilder new
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> beExpandableList [
	self
		blocItemViewModelStencil: CFMaExpanderItemViewModelStencilBuilder new;
		blocListStencil: CFMaExpandableListElementStencilBuilder new
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> beGrid [
	self
		blocItemViewModelStencil: GtMagritteModelStencilBuilder new;
		blocListStencil: CFMaGridElementStencilBuilder new
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> beSimpleList [
	self
		blocItemViewModelStencil: GtMagritteModelStencilBuilder new;
		blocListStencil: CFMaListElementStencilBuilder new
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> blocItemStencil [
	^ self
		propertyAt: #blocItemStencil
		ifAbsentPut: [ [ :anItemViewModel :anIndex :aListElement |
			CFCompactObjectStencil new
				object: anItemViewModel object;
				create ] asStencilBuilder: BrListRowStencilBuilder ]
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> blocItemStencil: aStencil [
	self
		propertyAt: #blocItemStencil
		put: (aStencil asStencilBuilder: BrListRowStencilBuilder)
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> blocListStencil [
	^ self
		propertyAt: #blocListStencil
		ifAbsent: [ CFMaListElementStencilBuilder new ]
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> blocListStencil: aStencil [
	self
		propertyAt: #blocListStencil
		put: (aStencil asStencilBuilder: GtMagritteListElementStencilBuilder)
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> newItemStencil [
	^ self propertyAt: #newItemStencil ifAbsent: [ nil ]
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> newItemStencil: aStencil [
	aStencil ifNil: [
		^ self propertyAt: #newItemStencil put: nil ].
	(aStencil isKindOf: BrStencil)
		ifTrue: [ ^ self propertyAt: #newItemStencil put: aStencil ].
	self
		propertyAt: #newItemStencil
		put: (aStencil asStencilBuilder: CFMaNewItemStencilBuilder)
]


{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> relationBodyInsets [
	^ self
		propertyAt: #cfMaRelationBodyInsets
		ifAbsent: [ BlInsets all: 6 ]
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> relationBodyInsets: anInsets [
	self propertyAt: #cfMaRelationBodyInsets put: anInsets
]


{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> relationGridItemInsets [
	^ self
		propertyAt: #cfMaRelationGridItemInsets
		ifAbsent: [ BlInsets all: 4 ]
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> relationGridItemInsets: anInsets [
	self propertyAt: #cfMaRelationGridItemInsets put: anInsets
]
