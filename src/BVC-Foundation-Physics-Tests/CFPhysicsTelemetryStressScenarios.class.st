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
			position: (((index - 1) \ columns) * 30) @ (((index - 1) // columns) * 30);
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
			position: islandOrigin + ((localIndex \ 2) * 18 @ ((localIndex // 2) * 18)) ].
	^ world
]
