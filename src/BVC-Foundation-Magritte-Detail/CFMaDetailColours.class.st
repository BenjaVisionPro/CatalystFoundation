Class {
	#name : 'CFMaDetailColours',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'foregrounds' }
CFMaDetailColours class >> primaryForeground [
	^ Color black
]

{ #category : 'foregrounds' }
CFMaDetailColours class >> secondaryForeground [
	^ Color black alpha: 0.8
]

{ #category : 'foregrounds' }
CFMaDetailColours class >> tertiaryForeground [
	^ Color black alpha: 0.55
]

{ #category : 'foregrounds' }
CFMaDetailColours class >> quaternaryForeground [
	^ Color black alpha: 0.35
]

{ #category : 'foregrounds' }
CFMaDetailColours class >> disabledForeground [
	^ Color black alpha: 0.22
]

{ #category : 'accent' }
CFMaDetailColours class >> highlight [
	^ CgtThemeState default highlightColor
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightBlue [
	^ CgtPalette highlightBlue
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightPurple [
	^ CgtPalette highlightPurple
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightPink [
	^ CgtPalette highlightPink
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightRed [
	^ CgtPalette highlightRed
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightOrange [
	^ CgtPalette highlightOrange
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightYellow [
	^ CgtPalette highlightYellow
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightGreen [
	^ CgtPalette highlightGreen
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightGrey [
	^ CgtPalette highlightGrey
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightColours [
	^ CgtPalette highlightColours
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightNameFor: aColour [
	^ CgtPalette highlightNameFor: aColour
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionBlue [
	^ CgtPalette textHighlightBlue
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionPurple [
	^ CgtPalette textHighlightPurple
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionPink [
	^ CgtPalette textHighlightPink
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionRed [
	^ CgtPalette textHighlightRed
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionOrange [
	^ CgtPalette textHighlightOrange
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionYellow [
	^ CgtPalette textHighlightYellow
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionGreen [
	^ CgtPalette textHighlightGreen
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionGraphite [
	^ CgtPalette textHighlightGraphite
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionColours [
	^ CgtPalette textHighlightColours
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionNameFor: aColour [
	^ CgtPalette textHighlightNameFor: aColour
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> automaticTextSelectionColourForHighlight: aHighlightColour [
	^ CgtPalette automaticTextHighlightColourForHighlight: aHighlightColour
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> resolveTextSelectionColour: aTextSelectionColour highlight: aHighlightColour [
	^ aTextSelectionColour ifNil: [
		self automaticTextSelectionColourForHighlight: aHighlightColour ]
]


{ #category : 'accent' }
CFMaDetailColours class >> textSelection [
	^ CgtThemeState default textHighlightColor
]


{ #category : 'accent' }
CFMaDetailColours class >> inactiveTextSelection [
	| aColour aGrey desaturation |
	aColour := self textSelection.
	aGrey := (aColour red * 0.2126)
		+ (aColour green * 0.7152)
		+ (aColour blue * 0.0722).
	desaturation := 0.50.
	^ Color
		r: (aColour red + ((aGrey - aColour red) * desaturation)) + ((1.0 - (aColour red + ((aGrey - aColour red) * desaturation))) * 0.30)
		g: (aColour green + ((aGrey - aColour green) * desaturation)) + ((1.0 - (aColour green + ((aGrey - aColour green) * desaturation))) * 0.30)
		b: (aColour blue + ((aGrey - aColour blue) * desaturation)) + ((1.0 - (aColour blue + ((aGrey - aColour blue) * desaturation))) * 0.30)
		alpha: aColour alpha
]
