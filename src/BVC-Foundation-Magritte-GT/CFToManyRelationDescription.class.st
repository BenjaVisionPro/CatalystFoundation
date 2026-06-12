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
			GtPhlowUtility newItemLabel
				text: anItemViewModel object gtDisplayText;
				yourself ] asStencilBuilder: BrListRowStencilBuilder ]
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
	(aStencil isKindOf: BrStencil)
		ifTrue: [ ^ self propertyAt: #newItemStencil put: aStencil ].
	self propertyAt: #newItemStencil put: (aStencil asStencilBuilder: CFMaNewItemStencilBuilder)
]

{ #category : 'api' }
CFToManyRelationDescription >> beColumnedList [
	self blocListStencil: CFMaColumnedListElementStencilBuilder new
]

{ #category : 'api' }
CFToManyRelationDescription >> beSimpleList [
	self blocListStencil: CFMaListElementStencilBuilder new
]

