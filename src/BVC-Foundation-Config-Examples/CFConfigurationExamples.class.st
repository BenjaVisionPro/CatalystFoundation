Class {
	#name : 'CFConfigurationExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Config-Examples',
	#package : 'BVC-Foundation-Config-Examples'
}

{ #category : 'configurations' }
CFConfigurationExamples class >> developmentConfiguration [
	<cfConfiguration>
	<return: #CFMyConfigExample>
	^ CFMyConfigExample new
		label: 'Development endpoint';
		endpoint: 'http://localhost:8080';
		yourself
]

{ #category : 'configurations' }
CFConfigurationExamples class >> developmentConfigurationWithoutTypeHint [
	<cfConfiguration>
	^ CFMyConfigExample new
		label: 'Development endpoint without type hint';
		endpoint: 'http://localhost:8081';
		yourself
]

{ #category : 'configurations' }
CFConfigurationExamples class >> emptyConfigurationGroup [
	<cfConfiguration>
	<return: #CFMyConfigurationGroupExample>
	^ CFMyConfigurationGroupExample new
		label: 'Empty configuration group';
		yourself
]

{ #category : 'configurations' }
CFConfigurationExamples class >> emptyConfigurationHolder [
	^ CFMyConfigurationHolderExample new
		label: 'Empty configuration holder';
		yourself
]

{ #category : 'configurations' }
CFConfigurationExamples class >> invalidConfiguration [
	^ CFMyConfigExample new
		label: 'Missing endpoint';
		yourself
]

{ #category : 'examples' }
CFConfigurationExamples >> invalidConfigurationHasStructuredIssue [
	<gtExample>
	| configuration result issue |
	configuration := CFMyConfigExample new
		label: 'Missing endpoint';
		yourself.
	result := CFConfigurationValidator new validate: configuration.
	self assert: result isValid not.
	issue := result errors first.
	self assert: issue code equals: #magritteValidation.
	self assert: issue subject == configuration.
	self assert: issue path equals: #(endpoint).
	^ result
]

{ #category : 'examples' }
CFConfigurationExamples >> methodLibraryDiscoversOptionalTypeHints [
	<gtExample>
	| library hintedAsset unhintedAsset |
	library := CFConfigurationLibrary discovered.
	hintedAsset := library assets
		detect: [ :each | each selector = #developmentConfiguration ].
	unhintedAsset := library assets
		detect: [ :each | each selector = #developmentConfigurationWithoutTypeHint ].
	self assert: hintedAsset configurationClass equals: CFMyConfigExample.
	self assert: unhintedAsset configurationClass isNil.
	self assert: hintedAsset materialize class equals: CFMyConfigExample.
	self assert: unhintedAsset materialize class equals: CFMyConfigExample.
	^ library
]

{ #category : 'examples' }
CFConfigurationExamples >> plannerFindsEmbeddedToManyPlacement [
	<gtExample>
	| configuration asset assessment targetChoice |
	configuration := self class emptyConfigurationGroup.
	asset := CFConfigurationLibrary discovered assets
		detect: [ :each | each selector = #developmentConfiguration ].
	assessment := CFConfigurationPlanner new
		assessAsset: asset
		in: configuration.
	self assert: assessment hasSingleTargetChoice.
	targetChoice := assessment targetChoices first.
	self assert: targetChoice placement owner == configuration.
	self assert: targetChoice placement isAddition.
	self assert: targetChoice willProduceValidConfiguration.
	self assert: configuration configurations isEmpty.
	^ assessment
]

{ #category : 'examples' }
CFConfigurationExamples >> plannerFindsNestedPlacements [
	<gtExample>
	| configuration nestedConfiguration asset assessment |
	configuration := self class emptyConfigurationGroup.
	nestedConfiguration := self class emptyConfigurationGroup.
	nestedConfiguration
		label: 'Nested configuration group';
		parent: configuration.
	configuration configurations add: nestedConfiguration.
	asset := CFConfigurationLibrary discovered assets
		detect: [ :each | each selector = #developmentConfiguration ].
	assessment := CFConfigurationPlanner new
		assessAsset: asset
		in: configuration.
	self assert: assessment targetChoices size equals: 2.
	self assert: (assessment targetChoices anySatisfy: [ :each |
		each placement owner == nestedConfiguration ]).
	self assert: configuration configurations size equals: 1.
	^ assessment
]

{ #category : 'examples' }
CFConfigurationExamples >> plannerFindsToOneReplacementPlacement [
	<gtExample>
	| configuration asset assessment targetChoice |
	configuration := self class emptyConfigurationHolder.
	asset := CFConfigurationLibrary discovered assets
		detect: [ :each | each selector = #developmentConfiguration ].
	assessment := CFConfigurationPlanner new
		assessAsset: asset
		in: configuration.
	self assert: assessment hasSingleTargetChoice.
	targetChoice := assessment targetChoices first.
	self assert: targetChoice placement isReplacement.
	self assert: targetChoice willProduceValidConfiguration.
	self assert: configuration configuration isNil.
	^ assessment
]

{ #category : 'examples' }
CFConfigurationExamples >> plannerRejectsPlacementThatAddsValidationErrors [
	<gtExample>
	| configuration asset assessment |
	configuration := self class emptyConfigurationGroup.
	asset := CFConfigurationMethodAsset new
		sourceClass: self class;
		selector: #invalidConfiguration;
		configurationClass: CFMyConfigExample;
		yourself.
	assessment := CFConfigurationPlanner new
		assessAsset: asset
		in: configuration.
	self assert: assessment targetChoices isEmpty.
	self assert: assessment diagnostics size equals: 1.
	^ assessment
]

{ #category : 'examples' }
CFConfigurationExamples >> serializationRoundTrip [
	<gtExample>
	| configuration decoded |
	configuration := self class developmentConfiguration.
	decoded := CFConfigurationCodec fromString: (CFConfigurationCodec toStringPretty: configuration).
	self assert: decoded class equals: CFMyConfigExample.
	self assert: decoded label equals: configuration label.
	self assert: decoded endpoint equals: configuration endpoint.
	^ decoded
]

{ #category : 'examples' }
CFConfigurationExamples >> serializationRoundTripRestoresConfigurationParents [
	<gtExample>
	| configuration decoded child |
	configuration := self class emptyConfigurationGroup.
	configuration configurations add: self class developmentConfiguration.
	decoded := CFConfigurationCodec fromString: (CFConfigurationCodec toStringPretty: configuration).
	child := decoded configurations first.
	self assert: child parent == decoded.
	^ decoded
]

{ #category : 'examples' }
CFConfigurationExamples >> validConfiguration [
	<gtExample>
	| configuration result |
	configuration := self class developmentConfiguration.
	result := CFConfigurationValidator new validate: configuration.
	self assert: result isValid.
	^ configuration
]
