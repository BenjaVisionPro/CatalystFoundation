"I provide the shared light environment used by Foundation interfaces. I map local time onto a continuous 24-hour light direction and provide the neutral Foundation background derived from that direction."

Class {
	#name : 'CFInterfaceLighting',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Core',
	#package : 'BVC-Foundation-Core'
}

{ #category : 'accessing' }
CFInterfaceLighting class >> backgroundPaint [
	"Deliberately high contrast while the shared light direction is being verified visually."
	^ (BlLinearGradientPaint direction: self lightDirection asPoint)
		from: (Color black alpha: 0.30)
		to: Color transparent
]

{ #category : 'accessing' }
CFInterfaceLighting class >> lightDirection [
	| now |
	now := DateAndTime now.
	^ self
		lightDirectionForHour: now hour
		minute: now minute
		second: now second
]

{ #category : 'private - calculation' }
CFInterfaceLighting class >> lightDirectionForHour: anHour minute: aMinute second: aSecond [
	| secondsInDay phase angle |
	secondsInDay := (anHour * 3600) + (aMinute * 60) + aSecond.
	phase := secondsInDay / 86400.0.
	angle := (Float pi / 2.0) + (phase * 2.0 * Float pi).
	^ (angle cos @ angle sin) asBlocVector normalized
]
