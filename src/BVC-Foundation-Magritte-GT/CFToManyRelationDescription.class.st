Class {
	#name : 'CFToManyRelationDescription',
	#superclass : 'MAToManyRelationDescription',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'accessing' }
CFToManyRelationDescription >> blocListStencil [
	^ self
		propertyAt: #blocListStencil
		ifAbsent: [ CFMaListElementStencilBuilder new ]
]

{ #category : 'accessing' }
CFToManyRelationDescription >> blocListStencil: aStencil [
	self
		propertyAt: #blocListStencil
		put: (aStencil asStencilBuilder: CFMaListElementStencilBuilder)
]
