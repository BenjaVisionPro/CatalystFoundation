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
CFPhlowTool class >> defaultViewModelClass [
	^ CFPhlowViewModel
]

{ #category : 'instance creation' }
CFPhlowTool class >> forSubject: anObject [
	^ self
		forSubject: anObject
		viewModelClass: self defaultViewModelClass
]

{ #category : 'instance creation' }
CFPhlowTool class >> forSubject: anObject viewModelClass: aViewModelClass [
	^ self new
		viewModel: (aViewModelClass forSubject: anObject);
		yourself
]

{ #category : 'converting' }
CFPhlowTool >> asElementDo: aBlock [
	^ aBlock cull: self viewModel asElement
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
CFPhlowTool >> priority [
	^ self viewModel toolPriority
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
