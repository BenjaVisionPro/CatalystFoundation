Class {
	#name : 'CFComposerElementBuilder',
	#superclass : 'GtMagritteElementBuilder',
	#instVars : [
		'formController',
		'showCommitAndResetControls'
	],
	#category : 'BVC-Foundation-Composer',
	#package : 'BVC-Foundation-Composer'
}

{ #category : 'private - building' }
CFComposerElementBuilder >> addComposerRelationUsing: aDescription [
	| anElement |
	anElement := CFComposerRelationElement
		memento: self memento
		description: aDescription
		formController: formController.
	self addFieldElement: anElement using: aDescription
]

{ #category : 'private - building' }
CFComposerElementBuilder >> addShortcutsTo: anElement [
	"Composer reset is coordinated by the root form controller. Keep GT's
	focus navigation, but deliberately omit its per-memento Escape reset."
	anElement
		addShortcut: (BlShortcutWithAction new
				name: 'Move to next form item';
				description: 'Moves to the next form item. If none is found, we cycle back to the first.';
				combination: (BlKeyCombination tab or: BlKeyCombination enter);
				overrideChildren: true;
				action: [ :anEvent |
					BlFocusFinder new
						direction: BlFocusSearchDirectionForward new;
						root: self form;
						referenceElement: anEvent target;
						nextFocusDo: #requestFocus ifNone: [  ] ]).
	anElement
		addShortcut: (BlShortcutWithAction new
				name: 'Move to previous form item';
				description: 'Moves to the previous form item. If none is found, we cycle back to the last.';
				combination: BlKeyCombination shiftTab;
				overrideChildren: true;
				action: [ :anEvent |
					BlFocusFinder new
						direction: BlFocusSearchDirectionBackward new;
						root: self form;
						referenceElement: anEvent target;
						nextFocusDo: #requestFocus ifNone: [  ] ])
]

{ #category : 'private - building' }
CFComposerElementBuilder >> addShortcutsTo: anElement using: aDescription [
	self addShortcutsTo: anElement.
	aDescription blocShortcuts ifNotNil: [ :aBlockReturningCollection |
		aBlockReturningCollection value do: [ :aShortcut | anElement addShortcut: aShortcut ] ]
]

{ #category : 'private - building' }
CFComposerElementBuilder >> buildActions [
	super buildActions.
	showCommitAndResetControls ifTrue: [
		self toolbarContainerDo: [ :aContainer |
			aContainer
				addChild: (CFComposerFormToolbarElement for: formController)
				as: #composerToolbar ] ]
]

{ #category : 'accessing' }
CFComposerElementBuilder >> formController [
	^ formController
]

{ #category : 'accessing' }
CFComposerElementBuilder >> formController: aComposerFormController [
	formController := aComposerFormController
]

{ #category : 'accessing' }
CFComposerElementBuilder >> showCommitAndResetControls: aBoolean [
	showCommitAndResetControls := aBoolean
]

{ #category : 'visiting-description' }
CFComposerElementBuilder >> visitToManyRelationDescription: aDescription [
	self addComposerRelationUsing: aDescription
]

{ #category : 'visiting-description' }
CFComposerElementBuilder >> visitToOneRelationDescription: aDescription [
	self addComposerRelationUsing: aDescription
]
