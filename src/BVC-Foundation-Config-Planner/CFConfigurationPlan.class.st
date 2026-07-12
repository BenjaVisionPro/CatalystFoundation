Class {
	#name : 'CFConfigurationPlan',
	#superclass : 'Object',
	#instVars : [
		'configurationAsset',
		'placement',
		'planner'
	],
	#category : 'BVC-Foundation-Config-Planner',
	#package : 'BVC-Foundation-Config-Planner'
}

{ #category : 'instance creation' }
CFConfigurationPlan class >> asset: aConfigurationAsset targetChoice: aTargetChoice planner: aPlanner [
	^ self new
		configurationAsset: aConfigurationAsset;
		placement: aTargetChoice placement;
		planner: aPlanner;
		yourself
]

{ #category : 'applying' }
CFConfigurationPlan >> apply [
	| configuration assessment targetChoice |
	configuration := configurationAsset materialize.
	assessment := planner
		assessConfiguration: configuration
		in: placement owner rootConfiguration.
	targetChoice := planner
		targetChoiceForPlacement: placement
		in: assessment.
	targetChoice ifNil: [
		self error: 'This configuration plan is no longer applicable to the configuration editor.' ].
	^ placement apply: configuration to: placement owner
]

{ #category : 'accessing' }
CFConfigurationPlan >> configurationAsset [
	^ configurationAsset
]

{ #category : 'accessing' }
CFConfigurationPlan >> configurationAsset: anObject [
	configurationAsset := anObject
]

{ #category : 'accessing' }
CFConfigurationPlan >> placement [
	^ placement
]

{ #category : 'accessing' }
CFConfigurationPlan >> placement: anObject [
	placement := anObject
]

{ #category : 'accessing' }
CFConfigurationPlan >> planner [
	^ planner
]

{ #category : 'accessing' }
CFConfigurationPlan >> planner: anObject [
	planner := anObject
]
