Class {
	#name : 'CFMaSettingsBaselineColumn',
	#superclass : 'BrVerticalPane',
	#category : 'BVC-Foundation-Magritte-GT-Elements',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Elements'
}

{ #category : 'layout' }
CFMaSettingsBaselineColumn >> baselineOffset [
	^ self children
		ifEmpty: [ 0 ]
		ifNotEmpty: [ :theChildren |
			| aFirstChild |
			aFirstChild := theChildren first.
			aFirstChild supportsBaseline
				ifTrue: [
					aFirstChild baselineOffset
						+ self padding top
						+ aFirstChild margin top ]
				ifFalse: [ 0 ] ]
]

{ #category : 'layout' }
CFMaSettingsBaselineColumn >> supportsBaseline [
	^ true
]
