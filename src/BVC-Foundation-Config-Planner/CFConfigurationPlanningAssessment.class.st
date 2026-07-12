Class {
	#name : 'CFConfigurationPlanningAssessment',
	#superclass : 'Object',
	#instVars : [
		'diagnostics',
		'targetChoices'
	],
	#category : 'BVC-Foundation-Config-Planner',
	#package : 'BVC-Foundation-Config-Planner'
}

{ #category : 'adding' }
CFConfigurationPlanningAssessment >> addDiagnostic: anObject [
	diagnostics add: anObject
]

{ #category : 'adding' }
CFConfigurationPlanningAssessment >> addTargetChoice: aChoice [
	targetChoices add: aChoice
]

{ #category : 'accessing' }
CFConfigurationPlanningAssessment >> diagnostics [
	^ diagnostics
]

{ #category : 'testing' }
CFConfigurationPlanningAssessment >> hasSingleTargetChoice [
	^ targetChoices size = 1
]

{ #category : 'initialization' }
CFConfigurationPlanningAssessment >> initialize [
	super initialize.
	targetChoices := OrderedCollection new.
	diagnostics := OrderedCollection new
]

{ #category : 'accessing' }
CFConfigurationPlanningAssessment >> targetChoices [
	^ targetChoices
]
