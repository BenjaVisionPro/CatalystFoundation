Class {
	#name : 'CFMaDetailAccessoryButton',
	#superclass : 'BrButton',
	#category : 'BVC-Foundation-Magritte-Detail-Elements',
	#package : 'BVC-Foundation-Magritte-Detail',
	#tag : 'Elements'
}

{ #category : 'layout' }
CFMaDetailAccessoryButton >> supportsBaseline [
	^ true
]

{ #category : 'layout' }
CFMaDetailAccessoryButton >> baselineOffset [
	| anIconHeight |
	anIconHeight := self icon measuredHeight.
	^ ((self measuredHeight - anIconHeight) / 2.0) + anIconHeight
]
