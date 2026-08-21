Class {
	#name : 'CFMaDetailPopupMetrics',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-Detail-Layout',
	#package : 'BVC-Foundation-Magritte-Detail',
	#tag : 'Layout'
}

{ #category : 'closed control' }
CFMaDetailPopupMetrics class >> controlHeight [
	^ 24
]

{ #category : 'closed control' }
CFMaDetailPopupMetrics class >> controlCornerRadius [
	^ 4
]

{ #category : 'closed control' }
CFMaDetailPopupMetrics class >> controlLeftInset [
	^ 12
]

{ #category : 'closed control' }
CFMaDetailPopupMetrics class >> controlRightInset [
	^ 4
]

{ #category : 'closed control' }
CFMaDetailPopupMetrics class >> indicatorExtent [
	^ 20 @ 20
]

{ #category : 'closed control' }
CFMaDetailPopupMetrics class >> indicatorGlyphExtent [
	^ 10 @ 10
]

{ #category : 'closed control' }
CFMaDetailPopupMetrics class >> labelIndicatorGap [
	^ 12
]

{ #category : 'appearance' }
CFMaDetailPopupMetrics class >> controlBackgroundColor [
	^ Color black alpha: 0.1
]

{ #category : 'menu' }
CFMaDetailPopupMetrics class >> menuInset [
	^ 5
]

{ #category : 'menu' }
CFMaDetailPopupMetrics class >> menuCornerRadius [
	^ 12
]

{ #category : 'menu' }
CFMaDetailPopupMetrics class >> optionHeight [
	^ self controlHeight
]

{ #category : 'menu' }
CFMaDetailPopupMetrics class >> optionLeftInset [
	^ 1
]

{ #category : 'menu' }
CFMaDetailPopupMetrics class >> optionRightInset [
	^ 8
]

{ #category : 'menu' }
CFMaDetailPopupMetrics class >> checkWidth [
	^ 14
]

{ #category : 'menu' }
CFMaDetailPopupMetrics class >> checkLabelGap [
	^ 2
]

{ #category : 'menu' }
CFMaDetailPopupMetrics class >> optionCornerRadius [
	^ self menuCornerRadius - self menuInset
]

{ #category : 'menu' }
CFMaDetailPopupMetrics class >> optionLabelOffset [
	^ self menuInset + self optionLeftInset + self checkWidth + self checkLabelGap
]

{ #category : 'menu' }
CFMaDetailPopupMetrics class >> menuHorizontalOffset [
	^ self controlLeftInset - self optionLabelOffset
]

{ #category : 'menu' }
CFMaDetailPopupMetrics class >> selectedRowOffsetForIndex: anIndex [
	^ self menuInset + (((anIndex max: 1) - 1) * self optionHeight)
]
