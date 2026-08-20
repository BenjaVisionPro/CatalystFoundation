Extension { #name : 'MADescription' }

{ #category : '*bvc-foundation-magritte-gt' }
MADescription >> smallSettingsIcon [
	^ self propertyAt: #cfSmallSettingsIcon put: true
]

{ #category : '*bvc-foundation-magritte-gt' }
MADescription >> usesSmallSettingsIcon [
	^ self propertyAt: #cfSmallSettingsIcon ifAbsent: [ false ]
]
