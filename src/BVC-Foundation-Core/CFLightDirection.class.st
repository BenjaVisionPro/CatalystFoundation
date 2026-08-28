"I provide Foundation light-direction geometry and time-of-day mapping. I convert manual angles to normalized directions and derive the current direction from local time."
Class {
	#name : 'CFLightDirection',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Core',
	#package : 'BVC-Foundation-Core'
}

{ #category : 'instance creation' }
CFLightDirection class >> forCurrentTimeOfDay [
	| now |
	now := DateAndTime now.
	^ self
		forHour: now hour
		minute: now minute
		second: now second
]

{ #category : 'instance creation' }
CFLightDirection class >> forHour: anHour minute: aMinute second: aSecond [
	| secondsInDay phase angle |
	secondsInDay := (anHour * 3600) + (aMinute * 60) + aSecond.
	phase := secondsInDay / 86400.0.
	angle := (Float pi / 2.0) + (phase * 2.0 * Float pi).
	^ (angle cos @ angle sin) asBlocVector normalized
]

{ #category : 'instance creation' }
CFLightDirection class >> fromDegrees: aNumber [
	| radians |
	radians := aNumber * Float pi / 180.0.
	^ (radians cos @ radians sin) asBlocVector normalized
]
