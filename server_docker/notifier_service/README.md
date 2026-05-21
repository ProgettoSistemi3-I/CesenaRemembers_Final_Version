# Cesena Remembers Notifier Service

Questo è un microservizio Node.js dockerizzato che ascolta le modifiche al database Firestore e invia notifiche Push (FCM) ai dispositivi quando ricevono una richiesta di amicizia.

## Istruzioni per l'Avvio

1. **Scarica la Service Account Key:**
   - Vai sulla Console di Firebase.
   - Apri "Impostazioni progetto" -> "Account di servizio".
   - Clicca su "Genera nuova chiave privata".
   - Rinomina il file scaricato in `serviceAccountKey.json` e posizionalo in QUESTA cartella (accanto a `index.js`). **NON COMMITTARE MAI QUESTO FILE SU GIT!**

2. **Crea l'immagine Docker:**
   Nel terminale, assicurati di essere dentro questa cartella (`notifier_service`) ed esegui:
   ```bash
   docker build -t cesena-notifier .
   ```

3. **Avvia il container:**
   ```bash
   docker run -d --name notifier cesena-notifier
   ```
   *Nota: `-d` lo avvia in background. Rimuovilo se vuoi vedere i log nel terminale, oppure usa `docker logs -f notifier`.*

## Come Funziona
Il server mantiene una cache locale dello stato di `receivedFriendRequests` per ogni utente. Quando rileva che l'array in Firestore si allunga, recupera i `fcmTokens` salvati in quel documento utente e invia un messaggio broadcast usando `admin.messaging().sendEachForMulticast()`.
