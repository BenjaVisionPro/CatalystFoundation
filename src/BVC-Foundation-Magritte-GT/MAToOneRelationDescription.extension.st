Extension { #name : 'MAToOneRelationDescription' }

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToOneRelationDescription >> beEmbeddedForm [
	self
		blocStencil: CFMaToOneEmbeddedFormStencilBuilder new;
		relationBodyInsets: BlInsets empty
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToOneRelationDescription >> bePhlowLink [
	self blocStencil: CFMaToOnePhlowLinkStencilBuilder new
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToOneRelationDescription >> beCompactList [
	self blocStencil: CFMaToOneElementStencilBuilder new
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToOneRelationDescription >> beColumnedList [
	self blocStencil: CFMaColumnedToOneElementStencilBuilder new
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
MAToOneRelationDescription >> blocItemStencil [
	^ self
		propertyAt: #blocItemStencil
		ifAbsentPut: [
			[ :anItemViewModel :anIndex :aListElement |
				CFCompactObjectStencil new
					object: anItemViewModel object;
					create ] asStencilBuilder: BrListRowStencilBuilder ]
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToOneRelationDescription >> blocItemStencil: aStencil [
	self
		propertyAt: #blocItemStencil
		put: (aStencil asStencilBuilder: BrListRowStencilBuilder)
]

{ #category : '*BVC-Foundation-Magritte-GT' }
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

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToOneRelationDescription >> newItemStencil: aStencil [
	(aStencil isKindOf: BrStencil)
		ifTrue: [ ^ self propertyAt: #newItemStencil put: aStencil ].
	self
		propertyAt: #newItemStencil
		put: (aStencil asStencilBuilder: CFMaNewItemStencilBuilder)
]


{ #category : '*BVC-Foundation-Magritte-GT' }
MAToOneRelationDescription >> relationBodyInsets [
	^ self
		propertyAt: #cfMaRelationBodyInsets
		ifAbsent: [ BlInsets all: 6 ]
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToOneRelationDescription >> relationBodyInsets: anInsets [
	self propertyAt: #cfMaRelationBodyInsets put: anInsets
]
