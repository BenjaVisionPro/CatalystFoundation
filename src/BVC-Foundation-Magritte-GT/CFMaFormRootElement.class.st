Class {
	#name : 'CFMaFormRootElement',
	#superclass : 'BrFrame',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}


{ #category : 'converting' }
CFMaFormRootElement >> asScrollableElement [
	^ super asScrollableElement
]

{ #category : 'initialization' }
CFMaFormRootElement >> initialize [
	"CFMaFormRootElement is the Phlow-facing async form host returned by CFMaViewModel.
	It must provide a full-area container for the generated Foundation form."
	super initialize.

	self
		background: CFInterfaceLighting backgroundPaint;
		hMatchParent;
		vFitContent
]

{ #category : 'configuration' }
CFMaFormRootElement >> beEmbedded [
	self
		hMatchParent;
		vFitContent
]
