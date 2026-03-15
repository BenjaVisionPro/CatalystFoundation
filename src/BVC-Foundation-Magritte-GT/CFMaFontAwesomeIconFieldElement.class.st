Class {
	#name : 'CFMaFontAwesomeIconFieldElement',
	#superclass : 'BrFrame',
	#traits : 'TGtMagritteWithFieldViewModel',
	#classTraits : 'TGtMagritteWithFieldViewModel classTrait',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'private' }
CFMaFontAwesomeIconFieldElement >> iconElementForValue: aValue [
	self fieldViewModel ifNil: [ ^ self newPlaceholderElement ].
	^ aValue
		ifNil: [ CFMaBuilderUtility newChooseIconAffordanceFor: self description ]
		ifNotNil: [ CFMaBuilderUtility newFontAwesomeIconFor: aValue using: self description ]
]

{ #category : 'initialization' }
CFMaFontAwesomeIconFieldElement >> initialize [
	super initialize.
	self
		beFocusable;
		fitContent;
		padding: (BlInsets all: 2).

	self
		addAptitude: (BrGlamorousWithExplicitDropdownAptitude
				handle: [ self newDropdownHandleElement ]
				content: [ self newDropdownContentElement ]).

	self
		withAsyncSinkDo: [ :anElementSink |
			anElementSink
				sink: AsyncPeekSink new;
				whenUpdate: [ :aContainer :aSink |
					self updateDisplayedIconFor: aSink value in: aContainer ] ]
]

{ #category : 'private' }
CFMaFontAwesomeIconFieldElement >> newDropdownContentElement [
	self fieldViewModel ifNil: [ ^ self newPlaceholderElement ].
	^ CFMaFontAwesomeIconSelectorElement new
		fieldViewModel: self fieldViewModel;
		dropdownAnchor: self;
		constraintsDo: [ :c |
			c horizontal exact: self description selectorExtent x.
			c vertical exact: self description selectorExtent y ];
		yourself
]

{ #category : 'private' }
CFMaFontAwesomeIconFieldElement >> newDropdownHandleElement [
	^ BrFrame new
		fitContent;
		padding: (BlInsets all: 2);
		constraintsDo: [ :c |
			c grid vertical alignCenter.
			c grid horizontal alignLeft ];
			addChild: (self iconElementForValue: self currentValue);
			yourself
]

{ #category : 'private' }
CFMaFontAwesomeIconFieldElement >> currentValue [
	self fieldViewModel ifNil: [ ^ nil ].
	self observableValue
		ifSome: [ :aValue | ^ aValue currentValue ].
	^ nil
]

{ #category : 'private' }
CFMaFontAwesomeIconFieldElement >> newPlaceholderElement [
	^ BrLabel new
		aptitude: BrLabelAptitude new;
		text: '';
		fitContent;
		yourself
]

{ #category : 'api - field view model' }
CFMaFontAwesomeIconFieldElement >> onFieldViewModelChanged [
	self inUIProcessDo: [
		self updateDisplayedIcon ]
]

{ #category : 'api - field view model' }
CFMaFontAwesomeIconFieldElement >> onPostFieldViewModelChanged [
	self withAsyncSinkDo: [ :anElementSink |
		self observableValue observe: anElementSink ]
]

{ #category : 'private' }
CFMaFontAwesomeIconFieldElement >> updateDisplayedIcon [
	self updateDisplayedIconFor: self currentValue in: self
]

{ #category : 'private' }
CFMaFontAwesomeIconFieldElement >> updateDisplayedIconFor: aValue in: aContainer [
	aContainer
		removeChildren;
		addChild: (self iconElementForValue: aValue)
]
