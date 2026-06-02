Class {
	#name : 'CFToManyRelationDescription',
	#superclass : 'MAToManyRelationDescription',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'accessing' }
CFToManyRelationDescription >> addItemChoices [
	self addItemChoicesStencil
		ifNotNil: [ :aStencil | ^ aStencil create ].

	^ self classes size > 1
		ifTrue: [ self classes ]
		ifFalse: [ #() ]
]

{ #category : 'accessing' }
CFToManyRelationDescription >> addItemChoicesStencil [
	^ self propertyAt: #addItemChoicesStencil ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CFToManyRelationDescription >> addItemChoicesStencil: aStencil [
	self propertyAt: #addItemChoicesStencil put: aStencil asStencil
]

{ #category : 'accessing' }
CFToManyRelationDescription >> addItemStencil [
	^ self propertyAt: #addItemStencil ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CFToManyRelationDescription >> addItemStencil: aStencil [
	self propertyAt: #addItemStencil put: aStencil asStencil
]

{ #category : 'accessing' }
CFToManyRelationDescription >> blocItemStencil [
	^ self
		propertyAt: #blocItemStencil
		ifAbsentPut: [ [ :anItem |
			anItem asGtMagritteViewModel asElement
				margin: (BlInsets top: 0 right: 10 bottom: 10 left: 0) ]
				asStencilBuilder: BrListRowStencilBuilder ]
]

{ #category : 'accessing' }
CFToManyRelationDescription >> blocListStencil [
	^ self
		propertyAt: #blocListStencil
		ifAbsent: [ CFMaSimpleListElementStencilBuilder new ]
]

{ #category : 'accessing' }
CFToManyRelationDescription >> blocListStencil: aStencil [
	self
		propertyAt: #blocListStencil
		put: (aStencil asStencilBuilder: CFMaListElementStencilBuilder)
]


{ #category : 'instance creation' }
CFToManyRelationDescription >> createAddItem [
	self addItemStencil
		ifNotNil: [ :aStencil |
			(aStencil respondsTo: #arguments:)
				ifTrue: [ aStencil arguments: #() ].
			^ aStencil create ].

	self newItemStencil
		ifNotNil: [ :aStencil | ^ aStencil create ].

	self classes size = 1
		ifTrue: [ ^ self classes first new ].

	^ nil
]

{ #category : 'instance creation' }
CFToManyRelationDescription >> createAddItemFromChoice: aChoice [
	self addItemStencil
		ifNotNil: [ :aStencil |
			(aStencil respondsTo: #arguments:)
				ifTrue: [ aStencil arguments: { aChoice } ].
			^ aStencil create ].

	(aChoice isClass)
		ifTrue: [ ^ aChoice new ].

	^ aChoice
]

{ #category : 'accessing' }
CFToManyRelationDescription >> emptyAddItemChoicesTooltip [
	^ self
		propertyAt: #emptyAddItemChoicesTooltip
		ifAbsent: [ 'There are no additional items that can be added.' ]
]

{ #category : 'accessing' }
CFToManyRelationDescription >> emptyAddItemChoicesTooltip: aString [
	self propertyAt: #emptyAddItemChoicesTooltip put: aString
]
