"
I am a Bloc element that renders one or more Font Awesome SVG paths directly.
I am intended to be produced by CFFontAwesomeIcons class-side factory methods and by the metadata importer.
"
Class {
	#name : 'CFFontAwesomeIcon',
	#superclass : 'BlElement',
	#instVars : [
		'pathElements',
		'pathRoles',
		'pathOpacities',
		'iconName',
		'styleKey',
		'unicode',
		'label',
		'viewBox',
		'primaryColor',
		'secondaryColor'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'styling' }
CFFontAwesomeIcon >> applyColors [
	1 to: pathElements size do: [ :index |
		| element role color alpha actualColor background |
		element := pathElements at: index.
		role := pathRoles at: index.
		color := role = #secondary
			ifTrue: [ secondaryColor ]
			ifFalse: [ primaryColor ].
		alpha := pathOpacities at: index ifAbsent: [ 1.0 ].
		actualColor := color alpha: alpha.
		background := BlBackground paint: (BlColorPaint color: actualColor).
		element background: background ]
]

{ #category : 'converting' }
CFFontAwesomeIcon >> asElement [
	^ self
]

{ #category : 'converting' }
CFFontAwesomeIcon >> asStencil [
	^ [ self ] asStencil
]

{ #category : 'accessing' }
CFFontAwesomeIcon >> color: aColor [
	primaryColor := aColor.
	secondaryColor := aColor.
	self applyColors.
	^ self
]

{ #category : 'styling' }
CFFontAwesomeIcon >> duotoneColorsPrimary: aPrimaryColor secondary: aSecondaryColor [
	primaryColor := aPrimaryColor.
	secondaryColor := aSecondaryColor.
	self applyColors.
	^ self
]

{ #category : 'accessing' }
CFFontAwesomeIcon >> iconName [
	^ iconName
]

{ #category : 'initialization' }
CFFontAwesomeIcon >> initializeName: aSelector styleKey: aStyleKey unicode: aUnicodeString label: aLabelString viewBox: aRectangle pathSpecs: pathSpecs [
	iconName := aSelector.
	styleKey := aStyleKey.
	unicode := aUnicodeString.
	label := aLabelString.
	viewBox := aRectangle.

	pathElements := OrderedCollection new.
	pathRoles := OrderedCollection new.
	pathOpacities := OrderedCollection new.

	pathSpecs
		do: [ :eachSpec | 
			| element role opacity |
			role := eachSpec at: #role ifAbsent: [ #primary ].
			opacity := eachSpec at: #opacity ifAbsent: [ 1.0 ].
			element := BlElement new
					geometry: (BlSvgPath new svg: (eachSpec at: #path) viewbox: aRectangle);
					yourself.
			self addChild: element.
			pathElements add: element.
			pathRoles add: role.
			pathOpacities add: opacity ].

	self resizeTo: aRectangle extent.

	primaryColor := Color black.
	secondaryColor := Color black.
	self applyColors.
	^ self
]

{ #category : 'accessing' }
CFFontAwesomeIcon >> label [
	^ label
]

{ #category : 'styling' }
CFFontAwesomeIcon >> primaryColor: aColor [
	primaryColor := aColor.
	self applyColors.
	^ self
]

{ #category : 'styling' }
CFFontAwesomeIcon >> secondaryColor: aColor [
	secondaryColor := aColor.
	self applyColors.
	^ self
]



{ #category : 'accessing' }
CFFontAwesomeIcon >> intrinsicExtent [
	^ viewBox extent
]

{ #category : 'sizing' }
CFFontAwesomeIcon >> height: aNumber [
	| intrinsic scale newWidth |
	intrinsic := self intrinsicExtent.
	(intrinsic y isZero or: [ aNumber isNil ]) ifTrue: [ ^ self ].
	scale := aNumber asFloat / intrinsic y asFloat.
	newWidth := intrinsic x asFloat * scale.
	self resizeTo: newWidth @ aNumber.
	^ self
]

{ #category : 'sizing' }
CFFontAwesomeIcon >> width: aNumber [
	| intrinsic scale newHeight |
	intrinsic := self intrinsicExtent.
	(intrinsic x isZero or: [ aNumber isNil ]) ifTrue: [ ^ self ].
	scale := aNumber asFloat / intrinsic x asFloat.
	newHeight := intrinsic y asFloat * scale.
	self resizeTo: aNumber @ newHeight.
	^ self
]

{ #category : 'sizing' }
CFFontAwesomeIcon >> fitInto: anExtent [
	| intrinsic xScale yScale scale |
	intrinsic := self intrinsicExtent.
	((intrinsic x isZero) or: [ intrinsic y isZero ] or: [ anExtent isNil ]) ifTrue: [ ^ self ].
	xScale := anExtent x asFloat / intrinsic x asFloat.
	yScale := anExtent y asFloat / intrinsic y asFloat.
	scale := xScale min: yScale.
	self resizeTo: ((intrinsic x asFloat * scale) @ (intrinsic y asFloat * scale)).
	^ self
]

{ #category : 'private' }
CFFontAwesomeIcon >> resizeTo: anExtent [
	self size: anExtent.
	pathElements do: [ :each | each size: anExtent ].
	^ self
]

{ #category : 'accessing' }
CFFontAwesomeIcon >> styleKey [
	^ styleKey
]

{ #category : 'accessing' }
CFFontAwesomeIcon >> unicode [
	^ unicode
]

{ #category : 'accessing' }
CFFontAwesomeIcon >> viewBox [
	^ viewBox
]
