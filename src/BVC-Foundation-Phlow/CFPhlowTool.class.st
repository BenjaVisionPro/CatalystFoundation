Class {
	#name : 'CFPhlowTool',
	#superclass : 'GtPhlowTool',
	#instVars : [
		'viewModel'
	],
	#category : 'BVC-Foundation-Phlow',
	#package : 'BVC-Foundation-Phlow'
}

{ #category : 'instance creation' }
CFPhlowTool class >> forSubject: aSubject [
	| aViewModelClass |
	aViewModelClass := (aSubject respondsTo: #cfPhlowViewModelClass)
		ifTrue: [ aSubject cfPhlowViewModelClass ]
		ifFalse: [ nil ].
	aViewModelClass ifNil: [ aViewModelClass := self defaultViewModelClass ].
	^ self new
		viewModel: (aViewModelClass forSubject: aSubject);
		yourself
]

{ #category : 'instance creation' }
CFPhlowTool class >> defaultViewModelClass [
	^ CFPhlowViewModel
]

{ #category : 'converting' }
CFPhlowTool >> asElementDo: aOneArgBlock [
	^ aOneArgBlock cull: self viewModel asElement
]

{ #category : 'api - accessing' }
CFPhlowTool >> icon [
	^ self viewModel toolIcon
]

{ #category : 'api - accessing' }
CFPhlowTool >> name [
	^ self viewModel toolName
]

{ #category : 'api - accessing' }
CFPhlowTool >> tabLook [
	^ BrGlamorousTabSwitcherWithIconAptitude
]

{ #category : 'accessing' }
CFPhlowTool >> viewModel [
	^ viewModel
]

{ #category : 'accessing' }
CFPhlowTool >> viewModel: aViewModel [
	viewModel := aViewModel
]
