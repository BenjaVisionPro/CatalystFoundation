Class {
	#name : 'CFToOneRelationDescription',
	#superclass : 'MAToOneRelationDescription',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'visiting' }
CFToOneRelationDescription >> acceptMagritte: aVisitor [
	^ aVisitor visitToOneRelationDescription: self
]

{ #category : 'accessing' }
CFToOneRelationDescription >> beEmbedded [
	self propertyAt: #beEmbedded put: true
]

{ #category : 'accessing' }
CFToOneRelationDescription >> beReferenced [
	self propertyAt: #beEmbedded put: false
]

{ #category : 'accessing' }
CFToOneRelationDescription >> blocStencil [
	^ self
		propertyAt: #blocStencil
		ifAbsent: [ CFMaToOneElementStencilBuilder new ]
]

{ #category : 'accessing' }
CFToOneRelationDescription >> blocStencil: aStencil [
	self
		propertyAt: #blocStencil
		put: (aStencil asStencilBuilder: CFMaToOneElementStencilBuilder)
]

{ #category : 'accessing' }
CFToOneRelationDescription >> blocItemViewModelStencil [
	^ self
		propertyAt: #blocItemViewModelStencil
		ifAbsent: [ GtMagritteModelStencilBuilder new ]
]

{ #category : 'accessing' }
CFToOneRelationDescription >> blocItemViewModelStencil: aStencil [
	self
		propertyAt: #blocItemViewModelStencil
		put: (aStencil asStencilBuilder: GtMagritteModelStencilBuilder)
]

{ #category : 'accessing' }
CFToOneRelationDescription >> isEmbedded [
	^ self propertyAt: #beEmbedded ifAbsent: [ false ]
]

{ #category : 'accessing' }
CFToOneRelationDescription >> newItemStencil [
	| theClasses |
	^ self
		propertyAt: #newItemStencil
		ifAbsent: [
			theClasses := self classes ifNil: [ #() ].
			theClasses isEmpty
				ifTrue: [ nil ]
				ifFalse: [ [ :aClass | aClass new ] ] ]
]

{ #category : 'accessing' }
CFToOneRelationDescription >> newItemStencil: aStencil [
	self propertyAt: #newItemStencil put: aStencil
]

{ #category : 'accessing' }
CFToOneRelationDescription >> blocItemStencil [
	^ self
		propertyAt: #blocItemStencil
		ifAbsentPut: [ self isEmbedded
			ifTrue: [ [ :anItemViewModel :anIndex :aListElement |
				anItemViewModel asElement ] asStencilBuilder: BrListRowStencilBuilder ]
			ifFalse: [ [ :anItemViewModel :anIndex :aListElement |
				GtPhlowUtility newItemLabel
					text: anItemViewModel object gtDisplayText;
					yourself ] asStencilBuilder: BrListRowStencilBuilder ] ]
]

{ #category : 'accessing' }
CFToOneRelationDescription >> blocItemStencil: aStencil [
	self
		propertyAt: #blocItemStencil
		put: (aStencil asStencilBuilder: BrListRowStencilBuilder)
]

{ #category : 'accessing' }
CFToOneRelationDescription >> blocListStencil [
	^ self blocStencil
]

{ #category : 'accessing' }
CFToOneRelationDescription >> blocListStencil: aStencil [
	self blocStencil: aStencil
]
