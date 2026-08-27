"I bridge optional semantic theme domains while Foundation elements are being constructed. I ask the effective theme for semantic values when it supports them and otherwise preserve the current Detail light defaults. I am compatibility glue, not part of the public theme API."
Class {
	#name : #CFThemeSemantics,
	#superclass : #Object,
	#category : #'BVC-Foundation-Magritte-GT'
}

{ #category : #'highlight' }
CFThemeSemantics class >> highlightColorFor: aTheme [
	| aColor |
	aColor := (aTheme respondsTo: #highlight)
		ifTrue: [ aTheme highlight color ]
		ifFalse: [ Color r: 52 g: 120 b: 247 range: 255 ].
	^ aColor blocResolveColorForTheme: aTheme
]

{ #category : #'highlight' }
CFThemeSemantics class >> textHighlightColorFor: aTheme [
	| aColor |
	aColor := (aTheme respondsTo: #highlight)
		ifTrue: [ aTheme highlight textColor ]
		ifFalse: [ Color r: 186 g: 213 b: 251 range: 255 ].
	^ aColor blocResolveColorForTheme: aTheme
]

{ #category : #'highlight' }
CFThemeSemantics class >> inactiveTextHighlightColorFor: aTheme [
	| aColor |
	aColor := (aTheme respondsTo: #highlight)
		ifTrue: [ aTheme highlight inactiveTextColor ]
		ifFalse: [ self inactiveTextHighlightColor ].
	^ aColor blocResolveColorForTheme: aTheme
]

{ #category : #'highlight' }
CFThemeSemantics class >> inactiveTextHighlightColor [
	| aColor aGrey desaturation aRed aGreen aBlue |
	aColor := Color r: 186 g: 213 b: 251 range: 255.
	aGrey := (aColor red * 0.2126) + (aColor green * 0.7152) + (aColor blue * 0.0722).
	desaturation := 0.50.
	aRed := aColor red + ((aGrey - aColor red) * desaturation).
	aGreen := aColor green + ((aGrey - aColor green) * desaturation).
	aBlue := aColor blue + ((aGrey - aColor blue) * desaturation).
	^ Color
		r: aRed + ((1.0 - aRed) * 0.30)
		g: aGreen + ((1.0 - aGreen) * 0.30)
		b: aBlue + ((1.0 - aBlue) * 0.30)
		alpha: aColor alpha
]

{ #category : #'typography' }
CFThemeSemantics class >> primaryForegroundFor: aTheme [
	| aColor |
	aColor := (aTheme respondsTo: #typography)
		ifTrue: [ aTheme typography primaryForeground ]
		ifFalse: [ aTheme colors primaryTextColor ].
	^ aColor blocResolveColorForTheme: aTheme
]

{ #category : #'typography' }
CFThemeSemantics class >> secondaryForegroundFor: aTheme [
	| aColor |
	aColor := (aTheme respondsTo: #typography)
		ifTrue: [ aTheme typography secondaryForeground ]
		ifFalse: [ aTheme colors secondaryTextColor ].
	^ aColor blocResolveColorForTheme: aTheme
]

{ #category : #'typography' }
CFThemeSemantics class >> tertiaryForegroundFor: aTheme [
	| aColor |
	aColor := (aTheme respondsTo: #typography)
		ifTrue: [ aTheme typography tertiaryForeground ]
		ifFalse: [ aTheme colors tertiaryTextColor ].
	^ aColor blocResolveColorForTheme: aTheme
]

{ #category : #'typography' }
CFThemeSemantics class >> bodyFontSizeFor: aTheme [
	^ (aTheme respondsTo: #typography)
		ifTrue: [ aTheme typography bodyFontSize ]
		ifFalse: [ 13 ]
]

{ #category : #'typography' }
CFThemeSemantics class >> supportingFontSizeFor: aTheme [
	^ (aTheme respondsTo: #typography)
		ifTrue: [ aTheme typography supportingFontSize ]
		ifFalse: [ 11 ]
]

{ #category : #'typography' }
CFThemeSemantics class >> groupHeadingFontSizeFor: aTheme [
	^ (aTheme respondsTo: #typography)
		ifTrue: [ aTheme typography groupHeadingFontSize ]
		ifFalse: [ 14 ]
]

{ #category : #'surfaces' }
CFThemeSemantics class >> formBackgroundFor: aTheme [
	| aColor |
	aColor := (aTheme respondsTo: #surfaces)
		ifTrue: [ aTheme surfaces formBackground ]
		ifFalse: [ aTheme colors contentBackgroundColor ].
	^ aColor blocResolveColorForTheme: aTheme
]

{ #category : #'surfaces' }
CFThemeSemantics class >> cardBackgroundFor: aTheme [
	| aColor |
	aColor := (aTheme respondsTo: #surfaces)
		ifTrue: [ aTheme surfaces cardBackground ]
		ifFalse: [ Color r: 248 g: 248 b: 248 range: 255 ].
	^ aColor blocResolveColorForTheme: aTheme
]

{ #category : #'surfaces' }
CFThemeSemantics class >> separatorColorFor: aTheme [
	| aColor |
	aColor := (aTheme respondsTo: #surfaces)
		ifTrue: [ aTheme surfaces separatorColor ]
		ifFalse: [ Color r: 229 g: 229 b: 229 range: 255 ].
	^ aColor blocResolveColorForTheme: aTheme
]
