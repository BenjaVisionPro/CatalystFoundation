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
	^ CgtFoundationPalette highlightBlue
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightPurple [
	^ CgtFoundationPalette highlightPurple
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightPink [
	^ CgtFoundationPalette highlightPink
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightRed [
	^ CgtFoundationPalette highlightRed
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightOrange [
	^ CgtFoundationPalette highlightOrange
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightYellow [
	^ CgtFoundationPalette highlightYellow
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightGreen [
	^ CgtFoundationPalette highlightGreen
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightGrey [
	^ CgtFoundationPalette highlightGrey
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightColours [
	^ CgtFoundationPalette highlightColours
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightNameFor: aColour [
	^ CgtFoundationPalette highlightNameFor: aColour
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionBlue [
	^ CgtFoundationPalette textHighlightBlue
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionPurple [
	^ CgtFoundationPalette textHighlightPurple
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionPink [
	^ CgtFoundationPalette textHighlightPink
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionRed [
	^ CgtFoundationPalette textHighlightRed
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionOrange [
	^ CgtFoundationPalette textHighlightOrange
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionYellow [
	^ CgtFoundationPalette textHighlightYellow
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionGreen [
	^ CgtFoundationPalette textHighlightGreen
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionGraphite [
	^ CgtFoundationPalette textHighlightGraphite
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionColours [
	^ CgtFoundationPalette textHighlightColours
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionNameFor: aColour [
	^ CgtFoundationPalette textHighlightNameFor: aColour
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> automaticTextSelectionColourForHighlight: aHighlightColour [
	^ CgtFoundationPalette automaticTextHighlightColourForHighlight: aHighlightColour
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
