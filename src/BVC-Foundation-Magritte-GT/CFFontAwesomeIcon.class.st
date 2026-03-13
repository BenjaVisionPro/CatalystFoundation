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
		| element role color background paint |
		element := pathElements at: index.
		role := pathRoles at: index.
		color := role = #secondary
			ifTrue: [ secondaryColor ]
			ifFalse: [ primaryColor ].
		paint := BlColorPaint color: color.
		(pathOpacities at: index ifAbsent: [ 1.0 ]) = 1.0
			ifFalse: [ paint := paint opacity: (pathOpacities at: index) ].
		background := BlBackground paint: paint.
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

	self size: aRectangle extent.

	pathElements := OrderedCollection new.
	pathRoles := OrderedCollection new.
	pathOpacities := OrderedCollection new.

	pathSpecs do: [ :eachSpec |
		| element role opacity |
		role := eachSpec at: #role ifAbsent: [ #primary ].
		opacity := eachSpec at: #opacity ifAbsent: [ 1.0 ].
		element := BlElement new
			geometry: (BlSvgPath new
				svg: (eachSpec at: #path);
				viewbox: aRectangle);
			yourself.
		self addChild: element.
		pathElements add: element.
		pathRoles add: role.
		pathOpacities add: opacity ].

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
