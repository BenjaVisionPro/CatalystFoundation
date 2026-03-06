Class {
	#name : 'BaselineOfCatalystFoundation',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfCatalystFoundation',
	#package : 'BaselineOfCatalystFoundation'
}

{ #category : 'loading' }
BaselineOfCatalystFoundation class >> loadLepiter [
	IceRepository registry  
		detect: [ :aRepository |
			aRepository name = 'CatalystFoundation' ]
		ifFound: [ :aRepository | 
			| defaultDatabase currentProperties |
			defaultDatabase := LeDatabasesRegistry defaultLogicalDatabase.
			currentProperties := defaultDatabase properties.
			currentProperties addRegisteredDirectory: aRepository repositoryDirectory / 'lepiter'.
			defaultDatabase reload ]
		ifNone: [
			self inform: 'Repository not found.' ]
]

{ #category : 'baseline' }
BaselineOfCatalystFoundation >> baseline: spec [

  <baseline>
  ^ spec for: #common do: [
        spec
          package: 'BVC-Foundation-Core';
          package: 'BVC-Foundation-Magritte-Core';
          package: 'BVC-Foundation-Magritte-GT';
          package: 'BVC-Foundation-Magritte-Seaside'
      ]
]
