"
I build compact, read-only Detail content for a Magritte relation reference.

I interpret the relation's reference descriptions against the related object. When a
reference description is also part of the related object's child memento, I observe that
memento value so the row reflects uncommitted edits. Specialized reference descriptions
that are not part of the child transaction are read directly from the related object.
"
Class {
	#name : 'CFMaDetailReferenceElementBuilder',
	#superclass : 'MAVisitor',
	#instVars : [
		'object',
		'memento',
		'presentation',
		'elements'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'accessing' }
CFMaDetailReferenceElementBuilder >> memento: aMemento [
	memento := aMemento
]

{ #category : 'accessing' }
CFMaDetailReferenceElementBuilder >> object: anObject [
	object := anObject
]

{ #category : 'accessing' }
CFMaDetailReferenceElementBuilder >> presentation: aPresentation [
	presentation := aPresentation
]

{ #category : 'building' }
CFMaDetailReferenceElementBuilder >> buildUsing: aReferenceDescription [
	| aContainer |
	elements := OrderedCollection new.
	self visit: aReferenceDescription asContainer.

	aContainer := BrHorizontalPane new
		hFitContent;
		vFitContent;
		cellSpacing: 6;
		padding: BlInsets empty;
		yourself.
	elements do: [ :anElement |
		anElement constraintsDo: [ :c | c linear vertical alignCenter ].
		aContainer addChild: anElement ].
	^ aContainer
]

{ #category : 'private - values' }
CFMaDetailReferenceElementBuilder >> hasTransactionalValueFor: aDescription [
	memento ifNil: [ ^ false ].
	^ memento magritteDescription includes: aDescription
]

{ #category : 'private - values' }
CFMaDetailReferenceElementBuilder >> staticValueFor: aDescription [
	^ aDescription read: object
]

{ #category : 'private - building' }
CFMaDetailReferenceElementBuilder >> updateIconHost: aHost value: aValue description: aDescription transactional: isTransactional [
	| aStencil anIcon |
	aHost removeChildren.
	aValue ifNil: [ ^ self ].

	aStencil := aDescription blocStencil
		model: aValue;
		description: aDescription.
	isTransactional ifTrue: [ aStencil memento: memento ].
	anIcon := aStencil asElement.
	aHost addChild: anIcon
]

{ #category : 'private - building' }
CFMaDetailReferenceElementBuilder >> updateLabel: aLabel value: aValue description: aDescription [
	| aString |
	aString := aDescription toString: aValue.
	aLabel
		text: aString asRopedText;
		visibility: (aString isEmpty
			ifTrue: [ BlVisibility gone ]
			ifFalse: [ BlVisibility visible ])
]

{ #category : 'visiting-description' }
CFMaDetailReferenceElementBuilder >> visitContainer: aDescription [
	aDescription do: [ :each |
		each isVisible ifTrue: [ self visit: each ] ]
]

{ #category : 'visiting-description' }
CFMaDetailReferenceElementBuilder >> visitElementDescription: aDescription [
	| aLabel |
	aLabel := BrLabel new
		aptitude: presentation defaultLabelAptitude;
		fitContent;
		yourself.
	elements add: aLabel.

	(self hasTransactionalValueFor: aDescription)
		ifTrue: [
			self
				updateLabel: aLabel
				value: (memento readObservableValueUsing: aDescription) currentValue
				description: aDescription.
			aLabel withAsyncSinkDo: [ :anElementSink |
				anElementSink
					sink: AsyncPeekSink new;
					whenUpdate: [ :theLabel :aSink |
						self
							updateLabel: theLabel
							value: aSink value currentValue
							description: aDescription ].
				(memento readObservableValueUsing: aDescription) observe: anElementSink ] ]
		ifFalse: [
			self
				updateLabel: aLabel
				value: (self staticValueFor: aDescription)
				description: aDescription ]
]

{ #category : 'visiting-description' }
CFMaDetailReferenceElementBuilder >> visitFontAwesomeIconDescription: aDescription [
	| aHost |
	aHost := BrFrame new
		hFitContent;
		vFitContent;
		yourself.
	elements add: aHost.

	(self hasTransactionalValueFor: aDescription)
		ifTrue: [
			self
				updateIconHost: aHost
				value: (memento readObservableValueUsing: aDescription) currentValue
				description: aDescription
				transactional: true.
			aHost withAsyncSinkDo: [ :anElementSink |
				anElementSink
					sink: AsyncPeekSink new;
					whenUpdate: [ :theHost :aSink |
						self
							updateIconHost: theHost
							value: aSink value currentValue
							description: aDescription
							transactional: true ].
				(memento readObservableValueUsing: aDescription) observe: anElementSink ] ]
		ifFalse: [
			self
				updateIconHost: aHost
				value: (self staticValueFor: aDescription)
				description: aDescription
				transactional: false ]
]
