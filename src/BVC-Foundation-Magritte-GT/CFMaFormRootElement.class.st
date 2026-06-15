Class {
	#name : 'CFMaFormRootElement',
	#superclass : 'BrFrame',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'converting' }
CFMaFormRootElement >> asScrollableElement [
	"Phlow wraps ordinary elements in a BlScrollableElement before installing them in an explicit view.
	Foundation forms own their internal body scroller, so the form root must opt out of that wrapping."
	^ self
]
