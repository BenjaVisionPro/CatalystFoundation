"
I wrap one or more Font Awesome SVG paths in a Bloc element and provide a small runtime API for color and size changes.
I am intended to be produced by CFFontAwesomeIcons class-side factory methods and by the metadata importer.
"
Class {
	#name : 'CFFontAwesomeIcon',
	#superclass : 'Object',
	#instVars : [
		'rootElement',
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
	^ rootElement
]

{ #category : 'converting' }
CFFontAwesomeIcon >> asStencil [
	^ [ self asElement ] asStencil
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

	rootElement := BlElement new.
	rootElement size: aRectangle extent.

	pathElements := pathCollection collect: [ :eachPath |
		BlElement new
			geometry: (BlSvgPath new
				svg: eachPath;
				viewbox: aRectangle);
			yourself ].

	pathElements do: [ :each | rootElement addChild: each ].
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
CFFontAwesomeIcon >> size: anExtent [
	rootElement size: anExtent.
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
