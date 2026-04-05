Class {
	#name : 'CFOperationsElement',
	#superclass : 'CFPhlowElement',
	#category : 'BVC-Foundation-Phlow',
	#package : 'BVC-Foundation-Phlow'
}

{ #category : 'instance creation' }
CFOperationsElement class >> newContentElementForViewModel: aViewModel [
	| anElement |
	anElement := self new.
	anElement viewModel: aViewModel.
	^ anElement buildOperationsContent
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
CFOperationsElement >> buildEditorSection [
	| aContainer |
	aContainer := self newSectionContainerWithBackground: (Color black alpha: 0.02).
	aContainer addChild: (self newSectionTitleLabel: self viewModel editorSectionTitle).
	aContainer addChild: self viewModel subject asGtMagritteViewModel asElement.
	^ aContainer
]

{ #category : 'private - building' }
CFOperationsElement >> buildOperationsContent [
	self removeChildren.
	self addChild: self buildBodySection.
	self viewModel supportsEmbeddedEditor ifTrue: [
		self addChild: self buildEditorSection ].
	^ self
]

{ #category : 'private - building' }
CFOperationsElement >> newSectionTitleLabel: aString [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.7));
		text: aString;
		hMatchParent;
		yourself
]

{ #category : 'accessing' }
CFOperationsElement >> viewModel: aViewModel [
	viewModel := aViewModel.
	self removeChildren.
	self
		hMatchParent;
		vFitContent;
		cellSpacing: 10.
	^ self
]
