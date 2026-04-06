Class {
	#name : 'CFPhlowElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'viewModel'
	],
	#category : 'BVC-Foundation-Phlow',
	#package : 'BVC-Foundation-Phlow'
}

{ #category : 'instance creation' }
CFPhlowElement class >> forViewModel: aViewModel [
	^ self new
		viewModel: aViewModel;
		yourself
]

{ #category : 'private - building' }
CFPhlowElement >> addSection: anElement to: aContainer [
	anElement ifNotNil: [ aContainer addChild: anElement ]
]

{ #category : 'private - building' }
CFPhlowElement >> buildContentSection [
	^ self viewModel contentElement
]

{ #category : 'private - building' }
CFPhlowElement >> buildContentViewport [
	| aContent aScrollable aViewport |
	aContent := self buildContentSection.
	aContent ifNil: [ ^ nil ].
	aContent hMatchParent.
	aScrollable := aContent asScrollableElement.
	aViewport := BrFrame new
		hMatchParent;
		vMatchParent;
		yourself.
	aViewport addChild: aScrollable.
	^ aViewport
]

{ #category : 'private - building' }
CFPhlowElement >> buildFooterSection [
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
CFPhlowElement >> buildHeaderSection [
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
CFPhlowElement >> initialize [
	super initialize.
	self
		hMatchParent;
		vMatchParent;
		padding: (BlInsets all: 8);
		cellSpacing: 10;
		background: (Color black alpha: 0.05)
]

{ #category : 'private - building' }
CFPhlowElement >> newSectionContainerWithBackground: aColor [
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 14);
		cellSpacing: 8;
		background: aColor;
		yourself
]

{ #category : 'private - building' }
CFPhlowElement >> rebuild [
	self removeChildren.
	viewModel ifNil: [ ^ self ].
	self addChild: self buildHeaderSection.
	self addSection: self buildContentViewport to: self.
	self addSection: self buildFooterSection to: self
]

{ #category : 'accessing' }
CFPhlowElement >> viewModel [
	^ viewModel
]

{ #category : 'accessing' }
CFPhlowElement >> viewModel: aViewModel [
	viewModel := aViewModel.
	self rebuild
]
