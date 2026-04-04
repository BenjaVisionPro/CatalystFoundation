Class {
	#name : 'CFOperationsTool',
	#superclass : 'GtPhlowTool',
	#instVars : [
		'viewModel'
	],
	#category : 'BVC-Foundation-Phlow',
	#package : 'BVC-Foundation-Phlow'
}

{ #category : 'instance creation' }
CFOperationsTool class >> forClass: aClass [
	^ self forSubject: aClass
]

{ #category : 'instance creation' }
CFOperationsTool class >> forObject: anObject [
	^ self forSubject: anObject
]

{ #category : 'instance creation' }
CFOperationsTool class >> forSubject: aSubject [
	| aViewModelClass |
	aViewModelClass := (aSubject respondsTo: #cfOperationsViewModelClass)
		ifTrue: [ aSubject cfOperationsViewModelClass ]
		ifFalse: [ CFOperationsViewModel ].
	^ self new
		viewModel: (aViewModelClass forSubject: aSubject);
		yourself
]

{ #category : 'converting' }
CFOperationsTool >> asElementDo: aOneArgBlock [
	^ aOneArgBlock cull: self viewModel asElement
]

{ #category : 'api - accessing' }
CFOperationsTool >> icon [
	^ self viewModel toolIcon
]

{ #category : 'api - accessing' }
CFOperationsTool >> name [
	^ self viewModel toolName
]

{ #category : 'api - accessing' }
CFOperationsTool >> tabLook [
	^ BrGlamorousTabSwitcherWithIconAptitude
]

{ #category : 'accessing' }
CFOperationsTool >> viewModel [
	^ viewModel
]

{ #category : 'accessing' }
CFOperationsTool >> viewModel: aViewModel [
	viewModel := aViewModel
]
