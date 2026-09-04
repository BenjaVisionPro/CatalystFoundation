Class {
	#name : 'CFComposerFormController',
	#superclass : 'Object',
	#instVars : [
		'rootMemento',
		'childMementos',
		'mementoChildren',
		'mementoParents',
		'mementosChangedActions'
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

{ #category : 'announcing' }
CFComposerFormController >> announceMementosChanged [
	mementosChangedActions do: [ :each | each value: self ]
]

{ #category : 'testing' }
CFComposerFormController >> canCommit [
	^ self hasChanges and: [ self isValid and: [ self isInactive ] ]
]

{ #category : 'testing' }
CFComposerFormController >> canReset [
	^ self hasChanges and: [ self isInactive ]
]

{ #category : 'accessing' }
CFComposerFormController >> childMementos [
	^ childMementos
]

{ #category : 'actions' }
CFComposerFormController >> commit [
	| allMementos |
	allMementos := self mementos.
	allMementos allButLast do: #commit.
	^ allMementos last commit
]

{ #category : 'testing' }
CFComposerFormController >> hasChanges [
	^ self statuses anySatisfy: [ :each | each isChanged ]
]

{ #category : 'initialization' }
CFComposerFormController >> initialize [
	super initialize.
	childMementos := IdentitySet new.
	mementoChildren := IdentityDictionary new.
	mementoParents := IdentityDictionary new.
	mementosChangedActions := OrderedCollection new
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

{ #category : 'private' }
CFComposerFormController >> mementosBelow: aMemento [
	| allMementos |
	allMementos := OrderedCollection new.
	(mementoChildren at: aMemento ifAbsent: [ #() ]) do: [ :each |
		allMementos addAll: (self mementosBelow: each) ].
	allMementos add: aMemento.
	^ allMementos
]

{ #category : 'registering' }
CFComposerFormController >> registerMemento: aMemento [
	^ self registerMemento: aMemento below: rootMemento
]

{ #category : 'registering' }
CFComposerFormController >> registerMemento: aMemento below: aParentMemento [
	| previousParent |
	aMemento == rootMemento ifTrue: [ ^ aMemento ].
	previousParent := mementoParents at: aMemento ifAbsent: [ nil ].
	previousParent == aParentMemento ifTrue: [ ^ aMemento ].
	previousParent ifNotNil: [
		(mementoChildren at: previousParent ifAbsent: [ #() ])
			remove: aMemento
			ifAbsent: [ ] ].
	childMementos add: aMemento.
	(mementoChildren at: aParentMemento ifAbsentPut: [ OrderedCollection new ])
		add: aMemento.
	mementoParents at: aMemento put: aParentMemento.
	self announceMementosChanged.
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
CFComposerFormController >> statuses [
	^ self mementos collect: [ :each |
		each overallStatus valueOrNil ] thenSelect: #isNotNil
]

{ #category : 'registering' }
CFComposerFormController >> unregisterMementoAndDescendants: aMemento [
	| allMementos parent |
	aMemento == rootMemento ifTrue: [ self error: 'The root memento belongs to the form controller' ].
	allMementos := self mementosBelow: aMemento.
	parent := mementoParents at: aMemento ifAbsent: [ nil ].
	parent ifNotNil: [
		(mementoChildren at: parent ifAbsent: [ #() ])
			remove: aMemento
			ifAbsent: [ ] ].
	allMementos do: [ :each |
		childMementos remove: each ifAbsent: [ ].
		mementoChildren removeKey: each ifAbsent: [ ].
		mementoParents removeKey: each ifAbsent: [ ] ].
	self announceMementosChanged
]

{ #category : 'announcing' }
CFComposerFormController >> whenMementosChangedDo: aBlock [
	mementosChangedActions add: aBlock
]
