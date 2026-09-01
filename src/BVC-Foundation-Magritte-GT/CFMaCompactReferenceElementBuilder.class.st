Class {
	#name : 'CFMaCompactReferenceElementBuilder',
	#superclass : 'CFMaReferenceElementBuilder',
	#instVars : [
		'element',
		'textIndex'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'building' }
CFMaCompactReferenceElementBuilder >> buildUsing: aReferenceDescription [
	textIndex := 0.
	element prepareForReference.
	self visit: aReferenceDescription asContainer.
	^ element
]

{ #category : 'accessing' }
CFMaCompactReferenceElementBuilder >> element: anElement [
	element := anElement
]

{ #category : 'private - building' }
CFMaCompactReferenceElementBuilder >> updateCompactIconValue: aValue description: aDescription transactional: isTransactional [
	| aStencil anIcon |
	aValue ifNil: [
		element hideReferenceIcon.
		^ self ].

	aStencil := aDescription blocStencil
		model: aValue;
		description: aDescription.
	isTransactional ifTrue: [ aStencil memento: memento ].
	anIcon := aStencil asElement.
	element referenceIcon: anIcon
]

{ #category : 'visiting-description' }
CFMaCompactReferenceElementBuilder >> visitElementDescription: aDescription [
	| aLabel |
	textIndex := textIndex + 1.
	aLabel := element newReferenceTextElementAt: textIndex.

	(self hasTransactionalValueFor: aDescription)
		ifTrue: [
			self
				updateLabel: aLabel
				value: (memento readUsing: aDescription)
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
CFMaCompactReferenceElementBuilder >> visitFontAwesomeIconDescription: aDescription [
	(self hasTransactionalValueFor: aDescription)
		ifTrue: [
			self
				updateCompactIconValue: (memento readUsing: aDescription)
				description: aDescription
				transactional: true.
			element withAsyncSinkDo: [ :anElementSink |
				anElementSink
					sink: AsyncPeekSink new;
					whenUpdate: [ :theElement :aSink |
						self
							updateCompactIconValue: aSink value currentValue
							description: aDescription
							transactional: true ].
				(memento readObservableValueUsing: aDescription) observe: anElementSink ] ]
		ifFalse: [
			self
				updateCompactIconValue: (self staticValueFor: aDescription)
				description: aDescription
				transactional: false ]
]
