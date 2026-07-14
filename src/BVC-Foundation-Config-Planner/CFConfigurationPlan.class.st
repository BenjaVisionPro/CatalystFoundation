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
	^ self applyConfiguration: configurationAsset materialize
]

{ #category : 'applying' }
CFConfigurationPlan >> applyConfiguration: aConfiguration [
	| assessment targetChoice rootConfiguration |
	rootConfiguration := placement memento model rootConfiguration.
	assessment := planner
		assessConfiguration: aConfiguration
		in: rootConfiguration.
	targetChoice := planner
		targetChoiceForPlacement: placement
		in: assessment.
	targetChoice ifNil: [
		self error: 'This configuration plan is no longer applicable to the configuration editor.' ].
	placement initializeObject: aConfiguration.
	^ placement apply: aConfiguration
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
