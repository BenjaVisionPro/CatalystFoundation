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
		ifAbsentPut: [ [ :anItem :anIndex :aListElement |
			GtPhlowUtility newItemLabel
				text: anItem gtDisplayText;
				yourself ] asStencilBuilder: BrListRowStencilBuilder ]
]

{ #category : 'accessing' }
CFToOneRelationDescription >> blocItemStencil: aStencil [
	self
		propertyAt: #blocItemStencil
		put: (aStencil asStencilBuilder: BrListRowStencilBuilder)
]

{ #category : 'accessing' }
CFToOneRelationDescription >> blocListStencil [
	^ self
		propertyAt: #blocListStencil
		ifAbsent: [ CFMaToOneElementStencilBuilder new ]
]

{ #category : 'accessing' }
CFToOneRelationDescription >> blocListStencil: aStencil [
	self
		propertyAt: #blocListStencil
		put: (aStencil asStencilBuilder: CFMaToOneElementStencilBuilder)
]
