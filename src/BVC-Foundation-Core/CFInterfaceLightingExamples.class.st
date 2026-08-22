"
I exercise the shared Foundation 24-hour light direction mapping.
"
Class {
	#name : 'CFInterfaceLightingExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Core',
	#package : 'BVC-Foundation-Core'
}

{ #category : 'examples' }
CFInterfaceLightingExamples >> evening [
	<gtExample>
	| direction |
	direction := CFInterfaceLighting
		lightDirectionForHour: 18
		minute: 0
		second: 0.
	self assert: (direction x - 1.0) abs < 0.000001.
	self assert: direction y abs < 0.000001.
	^ direction
]

{ #category : 'examples' }
CFInterfaceLightingExamples >> midday [
	<gtExample>
	| direction |
	direction := CFInterfaceLighting
		lightDirectionForHour: 12
		minute: 0
		second: 0.
	self assert: direction x abs < 0.000001.
	self assert: (direction y + 1.0) abs < 0.000001.
	^ direction
]

{ #category : 'examples' }
CFInterfaceLightingExamples >> midnight [
	<gtExample>
	| direction |
	direction := CFInterfaceLighting
		lightDirectionForHour: 0
		minute: 0
		second: 0.
	self assert: direction x abs < 0.000001.
	self assert: (direction y - 1.0) abs < 0.000001.
	^ direction
]

{ #category : 'examples' }
CFInterfaceLightingExamples >> morning [
	<gtExample>
	| direction |
	direction := CFInterfaceLighting
		lightDirectionForHour: 6
		minute: 0
		second: 0.
	self assert: (direction x + 1.0) abs < 0.000001.
	self assert: direction y abs < 0.000001.
	^ direction
]
