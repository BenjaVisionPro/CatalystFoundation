Class {
	#name : 'CFConfigurationTargetChoice',
	#superclass : 'Object',
	#instVars : [
		'placement',
		'validationResult'
	],
	#category : 'BVC-Foundation-Config-Planner',
	#package : 'BVC-Foundation-Config-Planner'
}

{ #category : 'instance creation' }
CFConfigurationTargetChoice class >> placement: aPlacement validationResult: aValidationResult [
	^ self new
		placement: aPlacement;
		validationResult: aValidationResult;
		yourself
]

{ #category : 'accessing' }
CFConfigurationTargetChoice >> placement [
	^ placement
]

{ #category : 'accessing' }
CFConfigurationTargetChoice >> placement: anObject [
	placement := anObject
]

{ #category : 'accessing' }
CFConfigurationTargetChoice >> validationResult [
	^ validationResult
]

{ #category : 'accessing' }
CFConfigurationTargetChoice >> validationResult: anObject [
	validationResult := anObject
]

{ #category : 'testing' }
CFConfigurationTargetChoice >> willProduceValidConfiguration [
	^ validationResult isValid
]
