Class {
	#name : 'CFPhysicsTelemetryStressScenarios',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Tests-Telemetry',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'private - construction' }
CFPhysicsTelemetryStressScenarios class >> boxElement [
	^ BlElement new
		geometry: BlRoundedRectangleGeometry new;
		size: 20 @ 20;
		yourself
]

{ #category : 'scenarios' }
CFPhysicsTelemetryStressScenarios class >> sleepingBodies: aBodyCount [
	| host elements world columns |
	host := BlElement new size: 1200 @ 800; yourself.
	elements := (1 to: aBodyCount) collect: [ :index |
		| element |
		element := self boxElement.
		host addChild: element.
		element ].
	world := host physics beWorld.
	world gravity: 0 @ 0; synchroniseMembership.
	columns := 20.
	elements withIndexDo: [ :element :index |
		(world bodyStateFor: element)
			position: (((index - 1) \\ columns) * 30) @ (((index - 1) // columns) * 30);
			sleep ].
	^ world
]

{ #category : 'scenarios' }
CFPhysicsTelemetryStressScenarios class >> densePileRows: rowCount columns: columnCount [
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
	world gravity: 0 @ 0; synchroniseMembership.
	elements do: [ :entry |
		(world bodyStateFor: entry first)
			position: ((entry second - 1) * 18) @ ((entry third - 1) * 18) ].
	^ world
]

{ #category : 'scenarios' }
CFPhysicsTelemetryStressScenarios class >> independentIslands: islandCount bodiesPerIsland: bodiesPerIsland [
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
	world gravity: 0 @ 0; synchroniseMembership.
	entries do: [ :entry |
		| islandOrigin localIndex |
		islandOrigin := ((entry second - 1) * 120) @ 0.
		localIndex := entry third - 1.
		(world bodyStateFor: entry first)
			position: islandOrigin + ((localIndex \\ 2) * 18 @ ((localIndex // 2) * 18)) ].
	^ world
]

{ #category : 'scenarios' }
CFPhysicsTelemetryStressScenarios class >> singleIslandBodies: aBodyCount [
	| host elements world |
	host := BlElement new size: 1600 @ 400; yourself.
	elements := (1 to: aBodyCount) collect: [ :index |
		| element |
		element := self boxElement.
		host addChild: element.
		element ].
	world := host physics beWorld.
	world gravity: 0 @ 0; synchroniseMembership.
	elements withIndexDo: [ :element :index |
		(world bodyStateFor: element)
			position: ((index - 1) * 18) @ 100 ].
	^ world
]

{ #category : 'scenarios' }
CFPhysicsTelemetryStressScenarios class >> sensorOverlapPairs: aPairCount [
	| host entries world |
	host := BlElement new size: 1600 @ 500; yourself.
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
	world gravity: 0 @ 0; synchroniseMembership.
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

{ #category : 'scenarios' }
CFPhysicsTelemetryStressScenarios class >> continuousCollisionBodies: aBodyCount [
	| host entries world |
	host := BlElement new size: 2000 @ 800; yourself.
	entries := OrderedCollection new.
	1 to: aBodyCount do: [ :index |
		| movingElement wallElement |
		movingElement := self boxElement.
		wallElement := self boxElement.
		host
			addChild: movingElement;
			addChild: wallElement.
		entries add: { movingElement. wallElement. index } ].
	world := host physics beWorld.
	world gravity: 0 @ 0; synchroniseMembership.
	entries do: [ :entry |
		| rowY |
		rowY := entry third * 35.
		(world bodyStateFor: entry first)
			position: 0 @ rowY;
			velocity: 20000 @ 0.
		(world bodyStateFor: entry second)
			position: 150 @ rowY;
			beStatic ].
	^ world
]
