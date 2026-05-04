# Cesena Remembers 1945

App Flutter educativa/gamificata per esplorare luoghi storici di Cesena con percorso su mappa, quiz e profilo utente.

## Architettura

Il progetto segue una struttura a layer ispirata a DDD/Clean Architecture:

- `lib/domain`
  - `entities`: modelli di dominio puri.
  - `repositories`: contratti astratti.
  - `usecases`: orchestrazione dei comportamenti applicativi.
  - `services`: logica di dominio (tour routing/scoring).
- `lib/data`
  - implementazioni concrete dei repository.
  - data source utente e seed locali dei POI.
- `lib/presentation`
  - pagine Flutter, widget e controller UI.
- `lib/core`
  - utilità trasversali (logging).

Dependency injection centralizzata in `lib/injection_container.dart` con `get_it`.

## Runtime e modalità operative

L'app usa:
- Firebase (auth + firestore)
- Mappe tile esterne
- Backend quiz AI (endpoint HTTP configurato internamente nel repository quiz)

### Quiz: fallback resiliente

Se il backend quiz non è disponibile, l'app usa automaticamente le domande seed locali (`HistoricPlacesSeed`) e mostra un avviso esplicito in UI: domande non personalizzate + difficoltà locale.

## Setup sviluppo

Prerequisiti:
- Flutter SDK (versione compatibile con `pubspec.yaml`)
- Dart SDK (incluso in Flutter)
- Configurazione Firebase valida per le piattaforme target

Comandi principali:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Setup produzione (linee guida)

- Verificare credenziali Firebase e file piattaforma (`google-services.json`, `GoogleService-Info.plist`).
- Validare disponibilità endpoint backend quiz.
- Eseguire quality gate minimo:
  - `flutter analyze`
  - `flutter test`
  - smoke test navigazione login → mappa → quiz → profilo.

## Qualità del codice

Pratiche adottate:
- separazione use case/repository/controller;
- riduzione commenti temporanei e marker di debug;
- logging strutturato via `dart:developer`.

## Licenza

Repository privato / uso interno progetto.
