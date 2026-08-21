Class {
	#name : 'CFMaDetailColours',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'foregrounds' }
CFMaDetailColours class >> primaryForeground [
	^ Color black
]

{ #category : 'foregrounds' }
CFMaDetailColours class >> secondaryForeground [
	^ Color black alpha: 0.8
]

{ #category : 'foregrounds' }
CFMaDetailColours class >> tertiaryForeground [
	^ Color black alpha: 0.55
]

{ #category : 'foregrounds' }
CFMaDetailColours class >> quaternaryForeground [
	^ Color black alpha: 0.35
]

{ #category : 'foregrounds' }
CFMaDetailColours class >> disabledForeground [
	^ Color black alpha: 0.22
]

{ #category : 'accent' }
CFMaDetailColours class >> highlight [
	^ Color r: 10 g: 132 b: 255 range: 255
]
