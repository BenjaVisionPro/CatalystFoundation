Class {
	#name : 'CFMaFieldElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'description',
		'memento',
		'editorElement'
	],
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'instance creation' }
CFMaFieldElement class >> description: aDescription memento: aMemento editorElement: anElement [
	^ self new
		description: aDescription;
		memento: aMemento;
		editorElement: anElement;
		yourself
]

{ #category : 'private - building' }
CFMaFieldElement >> buildFieldChrome [
	| aBorderContainer anInnerContainer aStatusIndicator |
	aBorderContainer := BrVerticalPane new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 18.0);
		background: (Color black alpha: 0.18);
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 1);
		yourself.

	anInnerContainer := BrHorizontalPane new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 17.0);
		background: (Color white alpha: 0.72);
		hMatchParent;
		vFitContent;
		padding: (self innerPadding);
		cellSpacing: 10;
		yourself.

	editorElement ifNotNil: [
		editorElement hMatchParent.
		anInnerContainer addChild: editorElement ].

	aStatusIndicator := self newStatusIndicator.
	aStatusIndicator ifNotNil: [ anInnerContainer addChild: aStatusIndicator ].

	aBorderContainer addChild: anInnerContainer.
	^ aBorderContainer
]

{ #category : 'private - building' }
CFMaFieldElement >> buildInteractionRow [
	| aRow aChrome aRevert |
	aRow := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 10;
		yourself.

	aChrome := self buildFieldChrome.
	aRow addChild: aChrome.

	aRevert := self newRevertAction.
	aRevert ifNotNil: [ aRow addChild: aRevert ].
	^ aRow
]

{ #category : 'private - building' }
CFMaFieldElement >> buildLabelElement [
	^ CFMaBuilderUtility newFieldLabelUsing: description
]

{ #category : 'accessing' }
CFMaFieldElement >> description [
	^ description
]

{ #category : 'accessing' }
CFMaFieldElement >> description: aDescription [
	description := aDescription.
	self rebuild
]

{ #category : 'accessing' }
CFMaFieldElement >> editorElement [
	^ editorElement
]

{ #category : 'accessing' }
CFMaFieldElement >> editorElement: anElement [
	editorElement := anElement.
	self rebuild
]

{ #category : 'initialization' }
CFMaFieldElement >> initialize [
	super initialize.
	self
		hMatchParent;
		vFitContent;
		cellSpacing: 6
]

{ #category : 'private - building' }
CFMaFieldElement >> innerPadding [
	^ (self isMultiLineDescription or: [ self isIconDescription ])
		ifTrue: [ BlInsets top: 14 right: 12 bottom: 14 left: 18 ]
		ifFalse: [ BlInsets top: 10 right: 12 bottom: 10 left: 18 ]
]

{ #category : 'testing' }
CFMaFieldElement >> isDirty [
	| aCurrentValue aModelValue |
	aCurrentValue := self currentValue.
	aModelValue := self modelValue.
	(aCurrentValue isNil and: [ aModelValue isNil ]) ifTrue: [ ^ false ].
	^ aCurrentValue ~= aModelValue
]

{ #category : 'testing' }
CFMaFieldElement >> isIconDescription [
	^ description class name asString includesSubstring: 'Icon'
]

{ #category : 'testing' }
CFMaFieldElement >> isMultiLineDescription [
	| aName |
	aName := description class name asString.
	^ (aName includesSubstring: 'Memo') or: [ aName includesSubstring: 'Multiline' ]
]

{ #category : 'testing' }
CFMaFieldElement >> isValidValue [
	| aCurrentValue aValidationResult |
	aCurrentValue := self currentValue.
	(memento respondsTo: #validateDescription:) ifTrue: [
		[ aValidationResult := memento perform: #validateDescription: with: description. ] on: Error do: [ ^ true ].
		^ aValidationResult = false ifTrue: [ false ] ifFalse: [ true ] ].
	(description respondsTo: #validate:) ifTrue: [
		[ description perform: #validate: with: aCurrentValue. ^ true ] on: Error do: [ ^ false ] ].
	^ true
]

{ #category : 'accessing' }
CFMaFieldElement >> memento [
	^ memento
]

{ #category : 'accessing' }
CFMaFieldElement >> memento: aMemento [
	memento := aMemento.
	self rebuild
]

{ #category : 'private - values' }
CFMaFieldElement >> modelObject [
	memento ifNil: [ ^ nil ].
	(memento respondsTo: #model) ifTrue: [ ^ memento perform: #model ].
	(memento respondsTo: #object) ifTrue: [ ^ memento perform: #object ].
	^ nil
]

{ #category : 'private - values' }
CFMaFieldElement >> modelValue [
	| anObject anAccessor |
	anObject := self modelObject.
	anObject ifNil: [ ^ nil ].
	anAccessor := self selectorAccessor.
	anAccessor ifNil: [ ^ nil ].
	(anObject respondsTo: anAccessor) ifFalse: [ ^ nil ].
	^ anObject perform: anAccessor
]

{ #category : 'private - building' }
CFMaFieldElement >> newRevertAction [
	self isDirty ifFalse: [ ^ nil ].
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.45));
		text: '↺';
		padding: (BlInsets top: 6 right: 4 bottom: 6 left: 4);
		margin: (BlInsets top: (self isMultiLineDescription ifTrue: [ 8 ] ifFalse: [ 4 ]));
		fitContent;
		when: BlClickEvent do: [ :anEvent | self revertToModelValue. anEvent consumed: true ];
		yourself
]

{ #category : 'private - building' }
CFMaFieldElement >> newStatusIndicator [
	| aColor |
	aColor := self statusColor.
	aColor ifNil: [ ^ nil ].
	^ BrFrame new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 8.0);
		background: aColor;
		size: 16@16;
		margin: (BlInsets top: (self isMultiLineDescription ifTrue: [ 4 ] ifFalse: [ 0 ]) bottom: 0 left: 0 right: 2);
		yourself
]

{ #category : 'private - building' }
CFMaFieldElement >> rebuild [
	(description isNil or: [ editorElement isNil or: [ memento isNil ] ]) ifTrue: [ ^ self ].
	self removeChildren.
	self
		addChild: self buildLabelElement;
		addChild: self buildInteractionRow
]

{ #category : 'private - actions' }
CFMaFieldElement >> revertToModelValue [
	| aModelValue |
	aModelValue := self modelValue.
	(memento respondsTo: #write:using:) ifTrue: [
		memento perform: #write:using: with: aModelValue with: description ].
	self rebuild.
	editorElement ifNotNil: [ editorElement requestStyle ]
]

{ #category : 'private - values' }
CFMaFieldElement >> selectorAccessor [
	| anAccessor |
	description ifNil: [ ^ nil ].
	(description respondsTo: #accessor) ifFalse: [ ^ nil ].
	anAccessor := description perform: #accessor.
	anAccessor ifNil: [ ^ nil ].
	^ anAccessor isSymbol
		ifTrue: [ anAccessor ]
		ifFalse: [ (anAccessor respondsTo: #asSymbol)
			ifTrue: [ anAccessor asSymbol ]
			ifFalse: [ nil ] ]
]

{ #category : 'private - values' }
CFMaFieldElement >> currentValue [
	(memento respondsTo: #readUsing:) ifTrue: [
		[ ^ memento perform: #readUsing: with: description ] on: Error do: [ ] ].
	^ self modelValue
]

{ #category : 'private - building' }
CFMaFieldElement >> statusColor [
	self isValidValue ifFalse: [ ^ (Color r: 0.78 g: 0.45 b: 0.46 alpha: 1.0) ].
	self isDirty ifTrue: [ ^ (Color r: 0.79 g: 0.67 b: 0.21 alpha: 1.0) ].
	^ nil
]
