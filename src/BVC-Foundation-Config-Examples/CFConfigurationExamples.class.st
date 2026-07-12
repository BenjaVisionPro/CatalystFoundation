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
CFConfigurationExamples >> validConfiguration [
	<gtExample>
	| configuration result |
	configuration := self class developmentConfiguration.
	result := CFConfigurationValidator new validate: configuration.
	self assert: result isValid.
	^ configuration
]
