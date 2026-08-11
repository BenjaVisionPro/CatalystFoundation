Class {
	#name : 'CFComposerFormController',
	#superclass : 'Object',
	#instVars : [
		'rootMemento',
		'childMementos'
	],
	#category : 'BVC-Foundation-Composer',
	#package : 'BVC-Foundation-Composer'
}

{ #category : 'instance creation' }
CFComposerFormController class >> withRootMemento: aMemento [
	^ self new
		rootMemento: aMemento;
		yourself
]

{ #category : 'actions' }
CFComposerFormController >> commit [
	childMementos do: #commit.
	^ rootMemento commit
]

{ #category : 'accessing' }
CFComposerFormController >> childMementos [
	^ childMementos
]

{ #category : 'initialization' }
CFComposerFormController >> initialize [
	super initialize.
	childMementos := IdentitySet new
]

{ #category : 'registering' }
CFComposerFormController >> registerMemento: aMemento [
	aMemento == rootMemento ifFalse: [ childMementos add: aMemento ].
	^ aMemento
]

{ #category : 'actions' }
CFComposerFormController >> reset [
	childMementos do: #reset.
	^ rootMemento reset
]

{ #category : 'accessing' }
CFComposerFormController >> rootMemento [
	^ rootMemento
]

{ #category : 'accessing' }
CFComposerFormController >> rootMemento: aMemento [
	rootMemento := aMemento
]
