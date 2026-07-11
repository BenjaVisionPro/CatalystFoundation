Class {
	#name : 'CFToManyRelationDescription',
	#superclass : 'MAToManyRelationDescription',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}



{ #category : 'accessing' }
CFToManyRelationDescription >> blocItemStencil [
	^ self
		propertyAt: #blocItemStencil
		ifAbsentPut: [ [ :anItemViewModel :anIndex :aListElement |
			CFCompactObjectStencil new
				object: anItemViewModel object;
				create ] asStencilBuilder: BrListRowStencilBuilder ]
]

{ #category : 'accessing' }
CFToManyRelationDescription >> blocItemStencil: aStencil [
	self
		propertyAt: #blocItemStencil
		put: (aStencil asStencilBuilder: BrListRowStencilBuilder)
]

{ #category : 'accessing' }
CFToManyRelationDescription >> blocListStencil [
	^ self
		propertyAt: #blocListStencil
		ifAbsent: [ CFMaListElementStencilBuilder new ]
]




{ #category : 'accessing' }
CFToManyRelationDescription >> newItemStencil [
	^ self propertyAt: #newItemStencil ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CFToManyRelationDescription >> newItemStencil: aStencil [
	aStencil ifNil: [
		^ self propertyAt: #newItemStencil put: nil ].
	(aStencil isKindOf: BrStencil)
		ifTrue: [ ^ self propertyAt: #newItemStencil put: aStencil ].
	self propertyAt: #newItemStencil put: (aStencil asStencilBuilder: CFMaNewItemStencilBuilder)
]

{ #category : 'api' }
CFToManyRelationDescription >> beAccordionList [
	self
		blocItemViewModelStencil: CFMaExpanderItemViewModelStencilBuilder new;
		blocListStencil: CFMaAccordionListElementStencilBuilder new
]

{ #category : 'api' }
CFToManyRelationDescription >> beColumnedList [
	self blocListStencil: CFMaColumnedListElementStencilBuilder new
]

{ #category : 'api' }
CFToManyRelationDescription >> beSimpleList [
	self blocListStencil: CFMaListElementStencilBuilder new
]
