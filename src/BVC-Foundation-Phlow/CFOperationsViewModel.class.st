Class {
	#name : 'CFOperationsViewModel',
	#superclass : 'Object',
	#instVars : [
		'subject'
	],
	#category : 'BVC-Foundation-Phlow',
	#package : 'BVC-Foundation-Phlow'
}

{ #category : 'instance creation' }
CFOperationsViewModel class >> forSubject: anObject [
	^ self new
		subject: anObject;
		yourself
]

{ #category : 'converting' }
CFOperationsViewModel >> asElement [
	^ self elementClass forViewModel: self
]

{ #category : 'accessing' }
CFOperationsViewModel >> bodySectionTitle [
	^ 'Overview'
]

{ #category : 'accessing' }
CFOperationsViewModel >> editorSectionTitle [
	^ 'Editor'
]

{ #category : 'accessing' }
CFOperationsViewModel >> elementClass [
	^ CFOperationsElement
]

{ #category : 'accessing' }
CFOperationsViewModel >> footerLines [
	^ #()
]

{ #category : 'accessing' }
CFOperationsViewModel >> headerMetadataText [
	| aSubject |
	aSubject := self subject.
	aSubject ifNil: [ ^ 'Catalyst Foundation operations' ].
	self isClassSubject ifTrue: [ ^ 'Class' ].
	^ aSubject class name
]

{ #category : 'accessing' }
CFOperationsViewModel >> headerTitleText [
	| aSubject aTitle |
	aSubject := self subject.
	aSubject ifNil: [ ^ 'Operations' ].
	self isClassSubject ifTrue: [ ^ aSubject name asString ].
	aTitle := (aSubject respondsTo: #label)
		ifTrue: [ aSubject perform: #label ]
		ifFalse: [ nil ].
	(aTitle isNil or: [ aTitle asString isEmpty ])
		ifTrue: [ aTitle := aSubject class name ].
	^ aTitle asString
]

{ #category : 'testing' }
CFOperationsViewModel >> hasFooter [
	^ self footerLines notEmpty
]

{ #category : 'testing' }
CFOperationsViewModel >> isClassSubject [
	^ self subject notNil and: [ self subject isBehavior ]
]

{ #category : 'accessing' }
CFOperationsViewModel >> sectionLines [
	| aSubject lines |
	aSubject := self subject.
	lines := OrderedCollection new.
	aSubject ifNil: [ ^ lines ].
	self isClassSubject
		ifTrue: [
			lines
				add: 'Type: Class';
				add: 'Name: ', aSubject name asString.
			^ lines ].
	(aSubject respondsTo: #identifier)
		ifTrue: [ lines add: 'Identifier: ', (aSubject perform: #identifier) asString ].
	(aSubject respondsTo: #status)
		ifTrue: [ lines add: 'Status: ', (aSubject perform: #status) asString ].
	(aSubject respondsTo: #enabled)
		ifTrue: [ lines add: 'Enabled: ', (aSubject perform: #enabled) asString ].
	(aSubject respondsTo: #priority)
		ifTrue: [ lines add: 'Priority: ', (aSubject perform: #priority) asString ].
	(aSubject respondsTo: #slug)
		ifTrue: [ lines add: 'Slug: ', (aSubject perform: #slug) asString ].
	^ lines
]

{ #category : 'accessing' }
CFOperationsViewModel >> subject [
	^ subject
]

{ #category : 'accessing' }
CFOperationsViewModel >> subject: anObject [
	subject := anObject
]

{ #category : 'testing' }
CFOperationsViewModel >> supportsEmbeddedEditor [
	^ self isClassSubject not
		and: [ self subject notNil and: [ self subject respondsTo: #asGtMagritteViewModel ] ]
]

{ #category : 'api - accessing' }
CFOperationsViewModel >> toolIcon [
	^ BrGlamorousVectorIcons browse
]

{ #category : 'api - accessing' }
CFOperationsViewModel >> toolName [
	^ 'operations'
]
