Class {
	#name : 'CFOperationsViewModel',
	#superclass : 'CFPhlowViewModel',
	#category : 'BVC-Foundation-Phlow',
	#package : 'BVC-Foundation-Phlow'
}

{ #category : 'accessing' }
CFOperationsViewModel >> bodySectionTitle [
	^ 'Overview'
]

{ #category : 'accessing' }
CFOperationsViewModel >> contentElement [
	^ self elementClass newContentElementForViewModel: self
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
CFOperationsViewModel >> headerMetadataText [
	^ 'Operations · ', super headerMetadataText
]

{ #category : 'accessing' }
CFOperationsViewModel >> sectionLines [
	| aSubject lines |
	aSubject := self subject.
	lines := OrderedCollection new.
	aSubject ifNil: [ ^ lines ].
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

{ #category : 'testing' }
CFOperationsViewModel >> supportsEmbeddedEditor [
	^ self subject notNil and: [ self subject respondsTo: #asGtMagritteViewModel ]
]

{ #category : 'api - accessing' }
CFOperationsViewModel >> toolName [
	^ 'operations'
]
