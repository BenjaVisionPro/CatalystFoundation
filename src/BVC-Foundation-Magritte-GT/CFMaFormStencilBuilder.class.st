Class {
	#name : 'CFMaFormStencilBuilder',
	#superclass : 'GtMagritteFormStencilBuilder',
	#instVars : [
		'labelLayout'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFMaFormStencilBuilder >> initialize [
	super initialize.
	labelLayout := CFMaInlineLabelLayout new
]

{ #category : 'accessing' }
CFMaFormStencilBuilder >> labelLayout [
	^ labelLayout
]

{ #category : 'accessing' }
CFMaFormStencilBuilder >> labelLayout: aLabelLayout [
	labelLayout := aLabelLayout
]

{ #category : 'configuration' }
CFMaFormStencilBuilder >> useInlineLabels [
	labelLayout := CFMaInlineLabelLayout new
]

{ #category : 'configuration' }
CFMaFormStencilBuilder >> useLeftLabels [
	labelLayout := CFMaLeftLabelLayout new
]

{ #category : 'api - instantiation' }
CFMaFormStencilBuilder >> buildDefault [
	^ labelLayout newFormContainer
]
