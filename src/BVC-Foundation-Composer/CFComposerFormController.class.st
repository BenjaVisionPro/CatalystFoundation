Class {
	#name : 'CFComposerFormController',
	#superclass : 'Object',
	#instVars : [
		'rootMemento',
		'childMementos',
		'mementoChildren'
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
	| allMementos |
	allMementos := self mementos.
	allMementos allButLast do: #commit.
	^ allMementos last commit
]

{ #category : 'accessing' }
CFComposerFormController >> childMementos [
	^ childMementos
]

{ #category : 'testing' }
CFComposerFormController >> canCommit [
	^ self hasChanges and: [ self isValid and: [ self isInactive ] ]
]

{ #category : 'testing' }
CFComposerFormController >> canReset [
	^ self hasChanges and: [ self isInactive ]
]

{ #category : 'initialization' }
CFComposerFormController >> initialize [
	super initialize.
	childMementos := IdentitySet new.
	mementoChildren := IdentityDictionary new
]

{ #category : 'testing' }
CFComposerFormController >> hasChanges [
	^ self statuses anySatisfy: [ :each | each isChanged ]
]

{ #category : 'testing' }
CFComposerFormController >> isInactive [
	^ self statuses size = self mementos size
		and: [ self statuses allSatisfy: [ :each | each isInactive ] ]
]

{ #category : 'testing' }
CFComposerFormController >> isValid [
	^ self statuses size = self mementos size
		and: [ self statuses allSatisfy: [ :each | each isValid ] ]
]

{ #category : 'accessing' }
CFComposerFormController >> mementos [
	^ self mementosBelow: rootMemento
]

{ #category : 'registering' }
CFComposerFormController >> registerMemento: aMemento [
	^ self registerMemento: aMemento below: rootMemento
]

{ #category : 'registering' }
CFComposerFormController >> registerMemento: aMemento below: aParentMemento [
	aMemento == rootMemento ifTrue: [ ^ aMemento ].
	childMementos add: aMemento.
	(mementoChildren at: aParentMemento ifAbsentPut: [ OrderedCollection new ])
		add: aMemento.
	^ aMemento
]

{ #category : 'actions' }
CFComposerFormController >> reset [
	| allMementos |
	allMementos := self mementos.
	allMementos allButLast do: #reset.
	^ allMementos last reset
]

{ #category : 'accessing' }
CFComposerFormController >> rootMemento [
	^ rootMemento
]

{ #category : 'accessing' }
CFComposerFormController >> rootMemento: aMemento [
	rootMemento := aMemento
]

{ #category : 'private' }
CFComposerFormController >> mementosBelow: aMemento [
	| allMementos |
	allMementos := OrderedCollection new.
	(mementoChildren at: aMemento ifAbsent: [ #() ]) do: [ :each |
		allMementos addAll: (self mementosBelow: each) ].
	allMementos add: aMemento.
	^ allMementos
]

{ #category : 'private' }
CFComposerFormController >> statuses [
	^ self mementos collect: [ :each |
		each overallStatus valueOrNil ] thenSelect: #isNotNil
]
