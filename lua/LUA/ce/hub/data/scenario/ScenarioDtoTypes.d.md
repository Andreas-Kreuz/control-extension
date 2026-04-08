# Scenario DTO

| Feld                 | Typ                | Bedeutung                 |
|----------------------|--------------------|---------------------------|
| `id`                 | `string`           | Singleton-ID              |
| `name`               | `string`           | Anzeigename               |
| `scenarioName`       | `string` \| `nil`  | Anlagenname               |
| `scenarioPath`       | `string` \| `nil`  | Pfad der Anlage           |
| `savedWithEep`       | `number` \| `nil`  | gespeicherte EEP-Version  |
| `scenarioLanguage`   | `string` \| `nil`  | Anlagensprache            |
| `eepLanguage`        | `string` \| `nil`  | Sprache der EEP-Instanz   |
| `activeTrain`        | `string` \| `nil`  | aktiver Zug               |
| `activeRollingStock` | `string` \| `nil`  | aktives Rollmaterial      |
| `timeLapse`          | `number` \| `nil`  | aktueller Zeitraffer      |
