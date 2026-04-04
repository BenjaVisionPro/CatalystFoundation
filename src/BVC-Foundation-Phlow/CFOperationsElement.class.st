Class {
	#name : 'CFOperationsElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'viewModel'
	],
	#category : 'BVC-Foundation-Phlow',
	#package : 'BVC-Foundation-Phlow'
}

{ #category : 'instance creation' }
CFOperationsElement class >> forViewModel: aViewModel [
	^ self new
		viewModel: aViewModel;
		yourself
]

{ #category : 'private - building' }
CFOperationsElement >> addSection: anElement to: aContainer [
	anElement ifNotNil: [ aContainer addChild: anElement ]
]

{ #category : 'private - building' }
CFOperationsElement >> buildBodySection [
	| aContainer |
	aContainer := self newSectionContainerWithBackground: (Color black alpha: 0.015).
	aContainer addChild: (self newSectionTitleLabel: self viewModel bodySectionTitle).
	self viewModel sectionLines do: [ :each |
		aContainer addChild: (BrLabel new
			aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.8));
			text: each;
			hMatchParent;
			yourself) ].
	^ aContainer
]

{ #category : 'private - building' }
CFOperationsElement >> buildContentSection [
	| aContainer |
	aContainer := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 10;
		yourself.
	self addSection: self buildBodySection to: aContainer.
	self viewModel supportsEmbeddedEditor ifTrue: [
		self addSection: self buildEditorSection to: aContainer ].
	^ aContainer
]

{ #category : 'private - building' }
CFOperationsElement >> buildEditorSection [
	| aContainer |
	aContainer := self newSectionContainerWithBackground: (Color black alpha: 0.02).
	aContainer addChild: (self newSectionTitleLabel: self viewModel editorSectionTitle).
	aContainer addChild: self viewModel subject asGtMagritteViewModel asElement.
	^ aContainer
]

{ #category : 'private - building' }
CFOperationsElement >> buildFooterSection [
	| aContainer |
	self viewModel hasFooter ifFalse: [ ^ nil ].
	aContainer := self newSectionContainerWithBackground: (Color black alpha: 0.025).
	self viewModel footerLines do: [ :each |
		aContainer addChild: (BrLabel new
			aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.7));
			text: each;
			hMatchParent;
			yourself) ].
	^ aContainer
]

{ #category : 'private - building' }
CFOperationsElement >> buildHeaderSection [
	| aContainer aTitle aMetadata |
	aContainer := self newSectionContainerWithBackground: (Color black alpha: 0.02).
	aContainer cellSpacing: 2.
	aTitle := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.9));
		text: self viewModel headerTitleText;
		hMatchParent;
		yourself.
	aMetadata := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.55));
		text: self viewModel headerMetadataText;
		hMatchParent;
		yourself.
	aContainer
		addChild: aTitle;
		addChild: aMetadata.
	^ aContainer
]

{ #category : 'initialization' }
CFOperationsElement >> initialize [
	super initialize.
	self
		hMatchParent;
		vMatchParent;
		padding: (BlInsets all: 10);
		cellSpacing: 10;
		background: (Color black alpha: 0.03)
]

{ #category : 'private - building' }
CFOperationsElement >> newSectionContainerWithBackground: aColor [
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 14);
		cellSpacing: 8;
		background: aColor;
		yourself
]

{ #category : 'private - building' }
CFOperationsElement >> newSectionTitleLabel: aString [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.7));
		text: aString;
		hMatchParent;
		yourself
]

{ #category : 'private - building' }
CFOperationsElement >> rebuild [
	self removeChildren.
	viewModel ifNil: [ ^ self ].
	self addChild: self buildHeaderSection.
	self addChild: self buildContentSection.
	self addSection: self buildFooterSection to: self
]

{ #category : 'accessing' }
CFOperationsElement >> viewModel [
	^ viewModel
]

{ #category : 'accessing' }
CFOperationsElement >> viewModel: aViewModel [
	viewModel := aViewModel.
	self rebuild
]
