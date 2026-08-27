Extension { #name : #BrTextEditorParagraphElement }

{ #category : #'*BVC-Foundation-Magritte-GT' }
BrTextEditorParagraphElement >> supportsBaseline [
	^ self textElements isNotEmpty
]

{ #category : #'*BVC-Foundation-Magritte-GT' }
BrTextEditorParagraphElement >> baselineOffset [
	| aTextElement |
	aTextElement := self textElements
		ifEmpty: [ ^ 0 ]
		ifNotEmpty: [ :theTextElements | theTextElements first ].
	aTextElement measure: BlExtentMeasurementSpec unspecified.
	^ self padding top + aTextElement baselineOffset
]
