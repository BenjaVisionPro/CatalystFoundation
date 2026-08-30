"I request Motion-driven dismissal after a popup option commits its value."

Class {
	#name : 'CFMaDetailPopupDismissRequest',
	#superclass : 'BlEvent',
	#instVars : [
		'handled'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailPopupDismissRequest >> initialize [
	super initialize.
	handled := false
]

{ #category : 'accessing' }
CFMaDetailPopupDismissRequest >> handled [
	^ handled
]

{ #category : 'accessing' }
CFMaDetailPopupDismissRequest >> handled: aBoolean [
	handled := aBoolean
]
