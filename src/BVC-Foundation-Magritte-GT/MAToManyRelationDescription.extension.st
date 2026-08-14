Extension { #name : 'MAToManyRelationDescription' }

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
