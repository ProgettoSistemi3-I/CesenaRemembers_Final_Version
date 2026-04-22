# Cesena Remembers

Applicazione Flutter per l'esplorazione storica con mappa, tour guidati, quiz e componenti social.

## Avvio locale

Assicurati di configurare le chiavi tramite `--dart-define` (non sono più hardcoded nel codice):

```bash
flutter run \
  --dart-define=GOOGLE_WEB_CLIENT_ID=your_google_web_client_id \
  --dart-define=MAPTILER_API_KEY=your_maptiler_key \
  --dart-define=STADIA_MAPS_API_KEY=your_stadia_key
```

## Note architetturali

- Layer principali: `domain`, `data`, `presentation`.
- La gestione mappe offline passa da `domain/repositories/offline_map_repository.dart` + `domain/usecases/offline_map_use_cases.dart`.
- La logica utente è stata separata in data source verticali (`profile`, `progress`, `social`, `cleanup`) per ridurre responsabilità monolitiche.
