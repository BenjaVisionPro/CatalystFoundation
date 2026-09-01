Extension { #name : 'MAToManyRelationDescription' }

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> newItemClassStencil [
	^ self propertyAt: #newItemClassStencil ifAbsent: [ nil ]
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAToManyRelationDescription >> newItemClassStencil: aStencil [
	self
		propertyAt: #newItemClassStencil
		put: (aStencil asStencilBuilder: CFMaNewItemStencilBuilder)
]
