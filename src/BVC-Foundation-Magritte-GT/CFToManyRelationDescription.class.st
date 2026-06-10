Class {
	#name : 'CFToManyRelationDescription',
	#superclass : 'MAToManyRelationDescription',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}



{ #category : 'accessing' }
CFToManyRelationDescription >> blocItemViewModelStencil [
	^ self
		propertyAt: #blocItemViewModelStencil
		ifAbsent: [ GtMagritteModelStencilBuilder new ]
]

{ #category : 'accessing' }
CFToManyRelationDescription >> blocItemViewModelStencil: aStencil [
	self
		propertyAt: #blocItemViewModelStencil
		put: (aStencil asStencilBuilder: GtMagritteModelStencilBuilder)
]

{ #category : 'accessing' }
CFToManyRelationDescription >> blocItemStencil [
	^ self
		propertyAt: #blocItemStencil
		ifAbsentPut: [ [ :anItemViewModel :anIndex :aListElement |
			| anObject |
			anObject := anItemViewModel respondsTo: #object
				ifTrue: [ anItemViewModel object ]
				ifFalse: [ anItemViewModel ].
			GtPhlowUtility newItemLabel
				text: anObject gtDisplayText;
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
CFToManyRelationDescription >> blocListStencil: aStencil [
	self
		propertyAt: #blocListStencil
		put: (aStencil asStencilBuilder: CFMaListElementStencilBuilder)
]
