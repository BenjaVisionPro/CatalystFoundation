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
	^ self highlightPurple
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightBlue [
	^ Color r: 52 g: 120 b: 247 range: 255
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightPurple [
	^ Color r: 153 g: 84 b: 163 range: 255
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightPink [
	^ Color r: 228 g: 92 b: 156 range: 255
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightRed [
	^ Color r: 237 g: 96 b: 93 range: 255
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightOrange [
	^ Color r: 232 g: 135 b: 58 range: 255
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightYellow [
	^ Color r: 245 g: 200 b: 68 range: 255
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightGreen [
	^ Color r: 120 g: 184 b: 86 range: 255
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightGrey [
	^ Color r: 141 g: 141 b: 140 range: 255
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightColours [
	^ {
		self highlightBlue.
		self highlightPurple.
		self highlightPink.
		self highlightRed.
		self highlightOrange.
		self highlightYellow.
		self highlightGreen.
		self highlightGrey }
]

{ #category : 'accent - highlight palette' }
CFMaDetailColours class >> highlightNameFor: aColour [
	aColour = self highlightBlue ifTrue: [ ^ 'Blue' ].
	aColour = self highlightPurple ifTrue: [ ^ 'Purple' ].
	aColour = self highlightPink ifTrue: [ ^ 'Pink' ].
	aColour = self highlightRed ifTrue: [ ^ 'Red' ].
	aColour = self highlightOrange ifTrue: [ ^ 'Orange' ].
	aColour = self highlightYellow ifTrue: [ ^ 'Yellow' ].
	aColour = self highlightGreen ifTrue: [ ^ 'Green' ].
	aColour = self highlightGrey ifTrue: [ ^ 'Grey' ].
	^ ''
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionBlue [
	^ Color r: 186 g: 213 b: 251 range: 255
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionPurple [
	^ Color r: 218 g: 197 b: 222 range: 255
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionPink [
	^ Color r: 245 g: 204 b: 225 range: 255
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionRed [
	^ Color r: 237 g: 197 b: 198 range: 255
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionOrange [
	^ Color r: 248 g: 219 b: 191 range: 255
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionYellow [
	^ Color r: 252 g: 238 b: 196 range: 255
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionGreen [
	^ Color r: 213 g: 233 b: 203 range: 255
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionGraphite [
	^ Color r: 223 g: 223 b: 224 range: 255
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionColours [
	^ {
		self textSelectionBlue.
		self textSelectionPurple.
		self textSelectionPink.
		self textSelectionRed.
		self textSelectionOrange.
		self textSelectionYellow.
		self textSelectionGreen.
		self textSelectionGraphite }
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> textSelectionNameFor: aColour [
	aColour ifNil: [ ^ 'Automatic' ].
	aColour = self textSelectionBlue ifTrue: [ ^ 'Blue' ].
	aColour = self textSelectionPurple ifTrue: [ ^ 'Purple' ].
	aColour = self textSelectionPink ifTrue: [ ^ 'Pink' ].
	aColour = self textSelectionRed ifTrue: [ ^ 'Red' ].
	aColour = self textSelectionOrange ifTrue: [ ^ 'Orange' ].
	aColour = self textSelectionYellow ifTrue: [ ^ 'Yellow' ].
	aColour = self textSelectionGreen ifTrue: [ ^ 'Green' ].
	aColour = self textSelectionGraphite ifTrue: [ ^ 'Graphite' ].
	^ ''
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> automaticTextSelectionColourForHighlight: aHighlightColour [
	| anIndex |
	anIndex := self highlightColours
		indexOf: aHighlightColour
		ifAbsent: [ 1 ].
	^ self textSelectionColours at: anIndex
]

{ #category : 'accent - text selection palette' }
CFMaDetailColours class >> resolveTextSelectionColour: aTextSelectionColour highlight: aHighlightColour [
	^ aTextSelectionColour ifNil: [
		self automaticTextSelectionColourForHighlight: aHighlightColour ]
]


{ #category : 'accent' }
CFMaDetailColours class >> textSelection [
	^ self
		resolveTextSelectionColour: nil
		highlight: self highlight
]


{ #category : 'accent' }
CFMaDetailColours class >> inactiveTextSelection [
	| aColour aGrey desaturation |
	aColour := self textSelection.
	aGrey := (aColour red * 0.2126)
		+ (aColour green * 0.7152)
		+ (aColour blue * 0.0722).
	desaturation := 0.18.
	^ Color
		r: aColour red + ((aGrey - aColour red) * desaturation)
		g: aColour green + ((aGrey - aColour green) * desaturation)
		b: aColour blue + ((aGrey - aColour blue) * desaturation)
		alpha: aColour alpha
]
