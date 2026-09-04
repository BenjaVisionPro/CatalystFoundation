Class {
	#name : 'CFComposerFormToolbarElement',
	#superclass : 'BrToolbar',
	#instVars : [
		'formController',
		'commitButton',
		'resetButton',
		'observedMementos'
	],
	#category : 'BVC-Foundation-Composer',
	#package : 'BVC-Foundation-Composer'
}

{ #category : 'instance creation' }
CFComposerFormToolbarElement class >> for: aComposerFormController [
	^ self new
		formController: aComposerFormController;
		build;
		yourself
]

{ #category : 'private - building' }
CFComposerFormToolbarElement >> build [
	commitButton := self newCommitButton.
	resetButton := self newResetButton.
	self
		addItem: commitButton;
		addItem: resetButton.
	self installStatusObservers.
	self updateButtonEnablement
]

{ #category : 'accessing' }
CFComposerFormToolbarElement >> formController: aComposerFormController [
	formController := aComposerFormController.
	formController whenMementosChangedDo: [ :aController |
		self installStatusObservers.
		self updateButtonEnablement ]
]

{ #category : 'initialization' }
CFComposerFormToolbarElement >> initialize [
	super initialize.
	observedMementos := IdentitySet new.
	self
		aptitude: GtMagritteToolbarAptitude new;
		hFitContentLimited;
		vFitContent;
		padding: (BlInsets top: 5 left: 0);
		constraintsDo: [ :c |
			c grid horizontal alignLeft.
			c grid horizontal span: 2.
			c linear horizontal alignLeft ]
]

{ #category : 'private - building' }
CFComposerFormToolbarElement >> installStatusObservers [
	formController mementos do: [ :aMemento |
		self observeStatusOf: aMemento ]
]

{ #category : 'private - building' }
CFComposerFormToolbarElement >> newCommitButton [
	^ BrButton new
		beFocusable;
		beTinySize;
		aptitude: BrGlamorousButtonWithIconAptitude;
		icon: BrGlamorousVectorIcons accept;
		label: 'Commit';
		margin: (BlInsets right: 4);
		action: [ :aButton |
			GtMagritteBuilderUtility
				awaitFuture: [ formController commit ] asAsyncFuture
				from: aButton ];
		yourself
]

{ #category : 'private - building' }
CFComposerFormToolbarElement >> newResetButton [
	^ BrButton new
		beFocusable;
		beTinySize;
		aptitude: BrGlamorousButtonWithIconAptitude;
		icon: BrGlamorousVectorIcons cancel;
		label: 'Reset';
		action: [ :aButton |
			GtMagritteBuilderUtility
				awaitFuture: [ formController reset ] asAsyncFuture
				from: aButton ];
		yourself
]

{ #category : 'private - building' }
CFComposerFormToolbarElement >> observeStatusOf: aMemento [
	(observedMementos includes: aMemento) ifTrue: [ ^ self ].
	observedMementos add: aMemento.
	self withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :anElement :aSink | anElement updateButtonEnablement ].
		aMemento overallStatus observe: anElementSink ]
]

{ #category : 'updating' }
CFComposerFormToolbarElement >> updateButtonEnablement [
	commitButton enabled: formController canCommit.
	resetButton enabled: formController canReset
]
