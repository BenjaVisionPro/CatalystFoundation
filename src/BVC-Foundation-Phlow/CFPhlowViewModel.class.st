Class {
	#name : 'CFPhlowViewModel',
	#superclass : 'Object',
	#instVars : [
		'subject'
	],
	#category : 'BVC-Foundation-Phlow',
	#package : 'BVC-Foundation-Phlow'
}

{ #category : 'instance creation' }
CFPhlowViewModel class >> forSubject: anObject [
	^ self new
		subject: anObject;
		yourself
]

{ #category : 'converting' }
CFPhlowViewModel >> asElement [
	^ self elementClass forViewModel: self
]

{ #category : 'accessing' }
CFPhlowViewModel >> elementClass [
	^ CFPhlowElement
]

{ #category : 'accessing' }
CFPhlowViewModel >> headerMetadataText [
	| aSubject |
	aSubject := self subject.
	aSubject ifNil: [ ^ 'Catalyst Foundation tool' ].
	^ aSubject class name
]

{ #category : 'accessing' }
CFPhlowViewModel >> headerTitleText [
	| aSubject aTitle |
	aSubject := self subject.
	aSubject ifNil: [ ^ self toolName capitalized ].
	aTitle := (aSubject respondsTo: #label)
		ifTrue: [ aSubject perform: #label ]
		ifFalse: [ nil ].
	(aTitle isNil or: [ aTitle asString isEmpty ])
		ifTrue: [ aTitle := aSubject class name ].
	^ aTitle asString
]

{ #category : 'testing' }
CFPhlowViewModel >> hasFooter [
	^ self footerLines notEmpty
]

{ #category : 'accessing' }
CFPhlowViewModel >> footerLines [
	^ #()
]

{ #category : 'accessing' }
CFPhlowViewModel >> contentElement [
	^ nil
]

{ #category : 'accessing' }
CFPhlowViewModel >> subject [
	^ subject
]

{ #category : 'accessing' }
CFPhlowViewModel >> subject: anObject [
	subject := anObject
]

{ #category : 'api - accessing' }
CFPhlowViewModel >> toolIcon [
	^ BrGlamorousVectorIcons browse
]

{ #category : 'api - accessing' }
CFPhlowViewModel >> toolName [
	^ 'tool'
]
