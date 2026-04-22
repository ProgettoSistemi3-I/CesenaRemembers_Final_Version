# Cesena Remembers 1945

App Flutter dedicata a un percorso storico-interattivo su Cesena durante la Seconda Guerra Mondiale.

## Funzionalità principali

- **Login Google + profilo utente** (setup iniziale con username univoco).
- **Mappa interattiva** con POI storici, navigazione e tour guidato.
- **Quiz per tappa** con assegnazione XP e aggiornamento statistiche.
- **Social & leaderboard**: ricerca utenti, amicizie, classifica globale.
- **Impostazioni utente**: tema, notifiche, GPS, mappe offline.

## Architettura

Il codice segue una separazione a layer:

- `lib/domain`: entità, contratti repository, use case e servizi di dominio.
- `lib/data`: implementazioni repository e data source (Firestore, seed locali, auth).
- `lib/presentation`: pagine UI, controller, servizi di navigazione/tema/permessi.

## Requisiti ambiente

- Flutter SDK compatibile con il progetto (`pubspec.yaml`).
- Firebase configurato (Auth + Firestore).
- Variabili compile-time opzionali:
  - `GOOGLE_WEB_CLIENT_ID`
  - `MAPTILER_API_KEY`
  - `STADIA_MAPS_API_KEY`

Esempio run:

```bash
flutter run \
  --dart-define=GOOGLE_WEB_CLIENT_ID=... \
  --dart-define=MAPTILER_API_KEY=... \
  --dart-define=STADIA_MAPS_API_KEY=...
```

## Note operative

- Le policy profilo/username sono implementate nel layer `domain/validation` + data source profilo.
- La leaderboard usa stream Firestore ordinato per XP.
- Il tour usa ordinamento nearest-neighbor e tracking posizione real-time.

## Qualità e test

Comandi consigliati in locale:

```bash
flutter pub get
flutter analyze
flutter test
```

> Nell'ambiente CI/sandbox usato per questa revisione, `flutter` potrebbe non essere disponibile.
