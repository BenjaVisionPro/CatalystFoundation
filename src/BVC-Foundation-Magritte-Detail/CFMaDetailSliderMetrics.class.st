Class {
	#name : 'CFMaDetailSliderMetrics',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-Detail-Layout',
	#package : 'BVC-Foundation-Magritte-Detail',
	#tag : 'Layout'
}

{ #category : 'thumb' }
CFMaDetailSliderMetrics class >> thumbExtent [
	^ 20 @ 16
]

{ #category : 'thumb' }
CFMaDetailSliderMetrics class >> thumbCornerRadius [
	^ self thumbExtent y / 2.0
]

{ #category : 'axis' }
CFMaDetailSliderMetrics class >> axisInset [
	^ self thumbExtent x / 2.0
]

{ #category : 'track' }
CFMaDetailSliderMetrics class >> trackHeight [
	^ 6.0
]

{ #category : 'track' }
CFMaDetailSliderMetrics class >> trackY [
	^ 6.0
]

{ #category : 'scale' }
CFMaDetailSliderMetrics class >> tickExtent [
	^ 2.5 @ 2.5
]

{ #category : 'scale' }
CFMaDetailSliderMetrics class >> tickY [
	^ 15.0
]

{ #category : 'labels' }
CFMaDetailSliderMetrics class >> labelY [
	^ 20.0
]

{ #category : 'measurement' }
CFMaDetailSliderMetrics class >> contentHeightBeforeLabels [
	^ self labelY
]
