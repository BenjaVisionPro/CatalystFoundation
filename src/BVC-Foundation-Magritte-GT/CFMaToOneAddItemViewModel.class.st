Class {
	#name : 'CFMaToOneAddItemViewModel',
	#superclass : 'CFMaAddItemViewModel',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'private - adding' }
CFMaToOneAddItemViewModel >> addItemForClass: aClass from: anElement [
	| aNewItem |
	self memento ifNil: [ ^ self ].
	self description ifNil: [ ^ self ].

	aNewItem := self createItemForClass: aClass.
	aNewItem ifNil: [ ^ self ].

	CFMaBuilderUtility
		addToOneObject: aNewItem
		memento: self memento
		using: self description
		element: anElement
]

{ #category : 'private - installing' }
CFMaToOneAddItemViewModel >> installAddButtonEnablementOn: aButton [
	self memento ifNil: [ ^ aButton disable; yourself ].
	self description ifNil: [ ^ aButton disable; yourself ].

	aButton
		withAsyncSinkDo: [ :anElementSink |
			anElementSink
				sink: AsyncPeekSink new;
				whenUpdate: [ :theButton :aSink |
					(aSink value currentValue isNil and: [ self shouldDisableAddButton not ])
						ifTrue: [ theButton enable ]
						ifFalse: [ theButton disable ] ].
			(self memento readObservableValueUsing: self description)
				observe: anElementSink ].

	^ aButton
]

{ #category : 'private - instance creation' }
CFMaToOneAddItemViewModel >> newClassChoiceAddElement [
	^ self installAddButtonEnablementOn: (super newClassChoiceAddElement)
]

{ #category : 'private - instance creation' }
CFMaToOneAddItemViewModel >> newImmediateAddButton [
	^ self installAddButtonEnablementOn: (super newImmediateAddButton)
]

{ #category : 'private - testing' }
CFMaToOneAddItemViewModel >> shouldDisableNewItemClass: aClass [
	| aCurrentValue |
	(super shouldDisableNewItemClass: aClass) ifTrue: [ ^ true ].
	aCurrentValue := self memento readUsing: self description.
	^ aCurrentValue isNotNil
]
