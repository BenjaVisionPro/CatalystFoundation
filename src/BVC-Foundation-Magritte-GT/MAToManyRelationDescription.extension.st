Extension { #name : 'MAToManyRelationDescription' }

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
		put: (aStencil asStencilBuilder: CFMaListElementStencilBuilder)
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToManyRelationDescription >> cfAddItemStencil [
	^ self propertyAt: #cfAddItemStencil ifAbsent: [ nil ]
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToManyRelationDescription >> cfAddItemStencil: aStencil [
	self propertyAt: #cfAddItemStencil put: aStencil asStencil
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToManyRelationDescription >> cfCanAddItems [
	^ self definitive not
		and: [ self cfHasNewItemStencil
			or: [ self cfHasAddItemStencil ] ]
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToManyRelationDescription >> cfHasAddItemStencil [
	^ self cfAddItemStencil isNotNil
]

{ #category : '*bvc-foundation-magritte-gt' }
MAToManyRelationDescription >> cfHasNewItemStencil [
	^ self newItemStencil isNotNil
]
