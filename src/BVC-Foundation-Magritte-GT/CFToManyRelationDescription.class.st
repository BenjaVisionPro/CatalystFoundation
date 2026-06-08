Class {
	#name : 'CFToManyRelationDescription',
	#superclass : 'MAToManyRelationDescription',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'accessing - add items' }
CFToManyRelationDescription >> addItemChoiceLabelBlock [
	^ self propertyAt: #addItemChoiceLabelBlock ifAbsent: [ nil ]
]

{ #category : 'accessing - add items' }
CFToManyRelationDescription >> addItemChoiceLabelBlock: aBlock [
	self propertyAt: #addItemChoiceLabelBlock put: aBlock
]

{ #category : 'accessing - add items' }
CFToManyRelationDescription >> addItemChoices [
	^ self
		propertyAt: #addItemChoices
		ifAbsent: [ self classes ]
]

{ #category : 'accessing - add items' }
CFToManyRelationDescription >> addItemChoices: aCollection [
	self propertyAt: #addItemChoices put: aCollection
]

{ #category : 'accessing - add items' }
CFToManyRelationDescription >> addItemClassBlock [
	^ self propertyAt: #addItemClassBlock ifAbsent: [ nil ]
]

{ #category : 'accessing - add items' }
CFToManyRelationDescription >> addItemClassBlock: aBlock [
	self propertyAt: #addItemClassBlock put: aBlock
]

{ #category : 'accessing - add items' }
CFToManyRelationDescription >> addItemClassForChoice: aChoice [
	self addItemClassBlock
		ifNotNil: [ :aBlock | ^ aBlock value: aChoice ].

	aChoice isClass
		ifTrue: [ ^ aChoice ].

	self error: 'No add-item class block configured for this add-item choice.'
]

{ #category : 'accessing - add items' }
CFToManyRelationDescription >> addItemFactoryBlock [
	^ self propertyAt: #addItemFactoryBlock ifAbsent: [ nil ]
]

{ #category : 'accessing - add items' }
CFToManyRelationDescription >> addItemFactoryBlock: aBlock [
	self propertyAt: #addItemFactoryBlock put: aBlock
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

{ #category : 'accessing - add items' }
CFToManyRelationDescription >> canCreateAddItem [
	self newItemStencil ifNotNil: [ ^ true ].
	self addItemFactoryBlock ifNotNil: [ ^ true ].
	self classes size = 1 ifTrue: [ ^ true ].
	^ self addItemChoices notEmpty
]

{ #category : 'instance creation' }
CFToManyRelationDescription >> createAddItem [
	self newItemStencil ifNotNil: [ :aStencil | ^ aStencil create ].

	self addItemChoices size = 1
		ifTrue: [ ^ self createAddItemFromChoice: self addItemChoices first ].

	self addItemFactoryBlock
		ifNotNil: [ :aBlock |
			aBlock numArgs = 0
				ifTrue: [ ^ aBlock value ] ].

	self classes size = 1 ifTrue: [ ^ self classes first new ].

	^ nil
]

{ #category : 'instance creation' }
CFToManyRelationDescription >> createAddItemFromChoice: aChoice [
	self addItemFactoryBlock
		ifNotNil: [ :aBlock |
			aBlock numArgs = 0
				ifTrue: [ ^ aBlock value ].
			^ aBlock value: aChoice ].

	^ (self addItemClassForChoice: aChoice) new
]

{ #category : 'accessing - add items' }
CFToManyRelationDescription >> emptyAddItemChoicesTooltip [
	^ self
		propertyAt: #emptyAddItemChoicesTooltip
		ifAbsent: [ 'There are no additional items that can be added.' ]
]

{ #category : 'accessing - add items' }
CFToManyRelationDescription >> emptyAddItemChoicesTooltip: aString [
	self propertyAt: #emptyAddItemChoicesTooltip put: aString
]

{ #category : 'accessing - add items' }
CFToManyRelationDescription >> labelForAddItemChoice: aChoice [
	self addItemChoiceLabelBlock
		ifNotNil: [ :aBlock | ^ aBlock value: aChoice ].

	(aChoice respondsTo: #displayName)
		ifTrue: [ ^ aChoice displayName ].

	(aChoice respondsTo: #name)
		ifTrue: [ ^ aChoice name ].

	^ aChoice asString
]

{ #category : 'accessing - add items' }
CFToManyRelationDescription >> requiresAddItemChoice [
	^ self addItemChoices size > 1
]

{ #category : 'accessing - compact list' }
CFToManyRelationDescription >> beCompactList [
	self propertyAt: #blocListStencil put: CFMaSimpleListElementStencilBuilder new.
	self blocItemViewModelStencil: [ :aModel :aDescription :aMemento |
		CFCompactListItemViewModel
			forObject: aModel
			description: [ self compactItemDescriptionFor: aModel ] ]
]

{ #category : 'accessing - compact list' }
CFToManyRelationDescription >> compactItemDescriptionBlock [
	^ self propertyAt: #compactItemDescriptionBlock ifAbsent: [ nil ]
]

{ #category : 'accessing - compact list' }
CFToManyRelationDescription >> compactItemDescriptionBlock: aBlock [
	self propertyAt: #compactItemDescriptionBlock put: aBlock
]

{ #category : 'accessing - compact list' }
CFToManyRelationDescription >> compactItemDescriptionFor: anObject [
	self compactItemDescriptionBlock
		ifNotNil: [ :aBlock | ^ aBlock value: anObject ].
	^ anObject magritteDescription
]
