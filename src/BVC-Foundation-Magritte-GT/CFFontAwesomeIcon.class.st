"
I am a Bloc element that renders one or more Font Awesome SVG paths directly.
I am intended to be produced by CFFontAwesomeIcons class-side factory methods and by the metadata importer.
"
Class {
	#name : 'CFFontAwesomeIcon',
	#superclass : 'BlElement',
	#instVars : [
		'pathElements',
		'iconName',
		'styleKey',
		'unicode',
		'label',
		'viewBox'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

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
	| background |
	background := BlBackground paint: (BlColorPaint color: aColor).
	pathElements do: [ :each | each background: background ].
	^ self
]

{ #category : 'initialization' }
CFFontAwesomeIcon >> initializeName: aSelector styleKey: aStyleKey unicode: aUnicodeString label: aLabelString viewBox: aRectangle paths: pathCollection [
	iconName := aSelector.
	styleKey := aStyleKey.
	unicode := aUnicodeString.
	label := aLabelString.
	viewBox := aRectangle.

	self size: aRectangle extent.

	pathElements := pathCollection collect: [ :eachPath |
		BlElement new
			geometry: (BlSvgPath new
				svg: eachPath;
				viewbox: aRectangle);
			yourself ].

	pathElements do: [ :each | self addChild: each ].
	self color: Color black.
	^ self
]

{ #category : 'accessing' }
CFFontAwesomeIcon >> iconName [
	^ iconName
]

{ #category : 'accessing' }
CFFontAwesomeIcon >> label [
	^ label
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
