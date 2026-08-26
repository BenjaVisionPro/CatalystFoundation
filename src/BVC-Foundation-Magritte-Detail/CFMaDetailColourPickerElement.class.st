Class {
	#name : 'CFMaDetailColourPickerElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'options',
		'value',
		'colourBlock',
		'labelBlock',
		'valueChangedBlock',
		'optionElements'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailColourPickerElement >> initialize [
	super initialize.
	options := #().
	colourBlock := [ :anOption | anOption ].
	labelBlock := [ :anOption |
		anOption ifNil: [ 'Automatic' ] ifNotNil: [ anOption printString ] ].
	valueChangedBlock := [ :anOption | ].
	optionElements := OrderedCollection new.
	self
		hFitContent;
		vFitContent;
		cellSpacing: 0;
		padding: BlInsets empty
]

{ #category : 'accessing' }
CFMaDetailColourPickerElement >> colourBlock: aBlock [
	colourBlock := aBlock.
	self rebuildOptions
]

{ #category : 'accessing' }
CFMaDetailColourPickerElement >> colours [
	^ options
]

{ #category : 'accessing' }
CFMaDetailColourPickerElement >> colours: aCollection [
	self options: aCollection
]

{ #category : 'accessing' }
CFMaDetailColourPickerElement >> labelBlock: aBlock [
	labelBlock := aBlock.
	self rebuildOptions
]

{ #category : 'accessing' }
CFMaDetailColourPickerElement >> options [
	^ options
]

{ #category : 'accessing' }
CFMaDetailColourPickerElement >> options: aCollection [
	options := aCollection asArray.
	self rebuildOptions
]

{ #category : 'private - building' }
CFMaDetailColourPickerElement >> rebuildOptions [
	self removeChildren.
	optionElements removeAll.
	options do: [ :anOption |
		| anElement |
		anElement := CFMaDetailColourPickerOptionElement new
			value: anOption;
			colour: (colourBlock cull: anOption);
			label: (labelBlock cull: anOption);
			activateBlock: [ :aSelectedElement |
				self selectValue: aSelectedElement value notify: true ];
			yourself.
		optionElements add: anElement.
		self addChild: anElement ].
	self updateSelection
]

{ #category : 'private - selection' }
CFMaDetailColourPickerElement >> selectValue: anOption notify: shouldNotify [
	value := anOption.
	self updateSelection.
	shouldNotify ifTrue: [ valueChangedBlock cull: value ]
]

{ #category : 'private - selection' }
CFMaDetailColourPickerElement >> updateSelection [
	optionElements do: [ :anElement |
		anElement selected: anElement value = value ]
]

{ #category : 'accessing' }
CFMaDetailColourPickerElement >> value [
	^ value
]

{ #category : 'accessing' }
CFMaDetailColourPickerElement >> value: anOption [
	self selectValue: anOption notify: false
]

{ #category : 'accessing' }
CFMaDetailColourPickerElement >> valueChangedBlock: aBlock [
	valueChangedBlock := aBlock
]
