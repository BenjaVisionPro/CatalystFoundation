"
I build repeatable Physics workloads for telemetry benchmarks.

My responsibility is to isolate representative simulation shapes so benchmark results can be compared consistently.
"
Class {
	#name : 'CFPhysicsTelemetryBenchmarkScenarios',
	#superclass : 'Object',
	#category : 'BVC-Physics-Examples',
	#package : 'BVC-Physics-Examples'
}

{ #category : 'private - construction' }
CFPhysicsTelemetryBenchmarkScenarios class >> boxElement [
	^ BlElement new
		geometry: BlRoundedRectangleGeometry new;
		size: 20 @ 20;
		yourself
]

{ #category : 'scenarios' }
CFPhysicsTelemetryBenchmarkScenarios class >> sleepingBodies: aBodyCount [
	| host elements world columns |
	host := BlElement new size: 1200 @ 800; yourself.
	elements := (1 to: aBodyCount) collect: [ :index |
		| element |
		element := self boxElement.
		host addChild: element.
		element ].
	world := host physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	columns := 20.
	elements withIndexDo: [ :element :index |
		(world bodyStateFor: element)
			position: (((index - 1) \\ columns) * 30) @ (((index - 1) // columns) * 30);
			sleep ].
	^ world
]

{ #category : 'scenarios' }
CFPhysicsTelemetryBenchmarkScenarios class >> densePileRows: rowCount columns: columnCount [
	| host elements world |
	host := BlElement new size: 1200 @ 800; yourself.
	elements := OrderedCollection new.
	1 to: rowCount do: [ :row |
		1 to: columnCount do: [ :column |
			| element |
			element := self boxElement.
			host addChild: element.
			elements add: { element. column. row } ] ].
	world := host physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	elements do: [ :entry |
		(world bodyStateFor: entry first)
			position: ((entry second - 1) * 18) @ ((entry third - 1) * 18) ].
	^ world
]

{ #category : 'scenarios' }
CFPhysicsTelemetryBenchmarkScenarios class >> independentIslands: islandCount bodiesPerIsland: bodiesPerIsland [
	| host entries world |
	host := BlElement new size: 1600 @ 900; yourself.
	entries := OrderedCollection new.
	1 to: islandCount do: [ :islandIndex |
		1 to: bodiesPerIsland do: [ :bodyIndex |
			| element |
			element := self boxElement.
			host addChild: element.
			entries add: { element. islandIndex. bodyIndex } ] ].
	world := host physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	entries do: [ :entry |
		| islandOrigin localIndex |
		islandOrigin := ((entry second - 1) * 120) @ 0.
		localIndex := entry third - 1.
		(world bodyStateFor: entry first)
			position: islandOrigin + ((localIndex \\ 2) * 18 @ ((localIndex // 2) * 18)) ].
	^ world
]

{ #category : 'scenarios' }
CFPhysicsTelemetryBenchmarkScenarios class >> singleIslandBodies: aBodyCount [
	| host elements world |
	host := BlElement new size: 2000 @ 400; yourself.
	elements := (1 to: aBodyCount) collect: [ :index |
		| element |
		element := self boxElement.
		host addChild: element.
		element ].
	world := host physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	elements withIndexDo: [ :element :index |
		(world bodyStateFor: element)
			position: ((index - 1) * 18) @ 100 ].
	^ world
]

{ #category : 'scenarios' }
CFPhysicsTelemetryBenchmarkScenarios class >> sensorOverlapPairs: aPairCount [
	| host entries world |
	host := BlElement new size: 2400 @ 500; yourself.
	entries := OrderedCollection new.
	1 to: aPairCount do: [ :index |
		| sensorElement solidElement |
		sensorElement := self boxElement.
		solidElement := self boxElement.
		host
			addChild: sensorElement;
			addChild: solidElement.
		entries add: { sensorElement. solidElement. index } ].
	world := host physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	entries do: [ :entry |
		| position |
		position := ((entry third - 1) * 40) @ 100.
		(world bodyStateFor: entry first)
			position: position;
			beStatic;
			beSensor.
		(world bodyStateFor: entry second)
			position: position ].
	^ world
]
