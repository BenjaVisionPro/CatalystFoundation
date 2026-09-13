"I interpolate one Atelier pager settle with prescribed initial velocity.

My initialSlope is the derivative of normalised travel with respect to normalised time at release. I use a cubic Hermite segment with position 0 and initialSlope at the release boundary, and position 1 with zero slope at the page boundary. This lets Foundation Motion continue the user's measured release velocity without a perceptible velocity discontinuity and arrive at the fixed page boundary at rest."
Class {
	#name : 'CFAtelierPageSettleInterpolator',
	#superclass : 'BlInterpolator',
	#instVars : [
		'initialSlope'
	],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'instance creation' }
CFAtelierPageSettleInterpolator class >> initialSlope: aNumber [
	^ self new
		initialSlope: aNumber;
		yourself
]

{ #category : 'accessing' }
CFAtelierPageSettleInterpolator >> initialSlope: aNumber [
	initialSlope := aNumber
]

{ #category : 'interpolation' }
CFAtelierPageSettleInterpolator >> interpolate: aProgress [
	| squared cubed |
	squared := aProgress * aProgress.
	cubed := squared * aProgress.
	^ ((initialSlope - 2.0) * cubed)
		+ ((3.0 - (2.0 * initialSlope)) * squared)
		+ (initialSlope * aProgress)
]
