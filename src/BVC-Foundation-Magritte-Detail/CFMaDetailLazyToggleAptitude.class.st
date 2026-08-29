Class {
	#name : 'CFMaDetailLazyToggleAptitude',
	#superclass : 'BrLazyStyleCommonAptitude',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : #'api - styles' }
CFMaDetailLazyToggleAptitude >> activated: aBlock [
	self
		when: [ :aState | BrToggleState activated ]
		style: aBlock
]

{ #category : #'api - styles' }
CFMaDetailLazyToggleAptitude >> deactivated: aBlock [
	self
		when: [ :aState | BrToggleState deactivated ]
		style: aBlock
]
