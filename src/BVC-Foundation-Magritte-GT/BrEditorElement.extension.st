Extension { #name : #BrEditorElement }

{ #category : #'*BVC-Foundation-Magritte-GT' }
BrEditorElement >> supportsBaseline [
	^ self children accountedByLayout anySatisfy: [ :aChild | aChild supportsBaseline ]
]

{ #category : #'*BVC-Foundation-Magritte-GT' }
BrEditorElement >> baselineOffset [
	| aBaselineChild |
	aBaselineChild := self children accountedByLayout
		detect: [ :aChild | aChild supportsBaseline ]
		ifNone: [ ^ 0 ].
	^ self padding top + aBaselineChild baselineOffset
]
