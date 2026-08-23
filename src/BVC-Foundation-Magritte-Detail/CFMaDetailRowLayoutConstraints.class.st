Class {
	#name : 'CFMaDetailRowLayoutConstraints',
	#superclass : 'BlLayoutConstraints',
	#instVars : [
		'leading',
		'description',
		'supporting',
		'content',
		'accessory',
		'trailing'
	],
	#category : 'BVC-Foundation-Magritte-Detail-Layout',
	#package : 'BVC-Foundation-Magritte-Detail',
	#tag : 'Layout'
}

{ #category : 'initialization' }
CFMaDetailRowLayoutConstraints >> initialize [
	super initialize.
	self clearRole
]

{ #category : 'private' }
CFMaDetailRowLayoutConstraints >> clearRole [
	leading := false.
	description := false.
	supporting := false.
	content := false.
	accessory := false.
	trailing := false
]

{ #category : 'api - role' }
CFMaDetailRowLayoutConstraints >> beLeading [
	self clearRole.
	leading := true
]

{ #category : 'api - role' }
CFMaDetailRowLayoutConstraints >> beDescription [
	self clearRole.
	description := true
]

{ #category : 'api - role' }
CFMaDetailRowLayoutConstraints >> beSupporting [
	self clearRole.
	supporting := true
]

{ #category : 'api - role' }
CFMaDetailRowLayoutConstraints >> beContent [
	self clearRole.
	content := true
]

{ #category : 'api - role' }
CFMaDetailRowLayoutConstraints >> beAccessory [
	self clearRole.
	accessory := true
]

{ #category : 'api - role' }
CFMaDetailRowLayoutConstraints >> beTrailing [
	self clearRole.
	trailing := true
]

{ #category : 'testing' }
CFMaDetailRowLayoutConstraints >> isLeading [
	^ leading
]

{ #category : 'testing' }
CFMaDetailRowLayoutConstraints >> isDescription [
	^ description
]

{ #category : 'testing' }
CFMaDetailRowLayoutConstraints >> isSupporting [
	^ supporting
]

{ #category : 'testing' }
CFMaDetailRowLayoutConstraints >> isContent [
	^ content
]

{ #category : 'testing' }
CFMaDetailRowLayoutConstraints >> isAccessory [
	^ accessory
]

{ #category : 'testing' }
CFMaDetailRowLayoutConstraints >> isTrailing [
	^ trailing
]
