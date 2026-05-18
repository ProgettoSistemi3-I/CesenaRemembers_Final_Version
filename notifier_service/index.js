const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Verifica la presenza della chiave
const keyPath = path.join(__dirname, 'serviceAccountKey.json');
if (!fs.existsSync(keyPath)) {
  console.error("ERRORE CRITICO: Il file 'serviceAccountKey.json' non e' presente.");
  console.error("Scaricalo dalla console di Firebase (Impostazioni Progetto -> Account di Servizio) e inseriscilo in questa cartella.");
  process.exit(1);
}

const serviceAccount = require(keyPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

console.log("🚀 Notifier Service avviato. In ascolto su modifiche alla collection 'users'...");

// Ascolta tutte le modifiche ai documenti nella collection 'users'
db.collection('users').onSnapshot(snapshot => {
  snapshot.docChanges().forEach(async (change) => {
    // Ci interessa solo quando un documento viene modificato (non creato o cancellato)
    if (change.type === 'modified') {
      const newData = change.doc.data();
      
      // Estrarre dati necessari
      const receivedRequests = newData.receivedFriendRequests || [];
      const fcmTokens = newData.fcmTokens || [];
      const userId = change.doc.id;

      // Recuperiamo i dati prima della modifica per fare un confronto
      // Attenzione: onSnapshot in tempo reale non fornisce direttamente il "before", 
      // in un ambiente server puro a volte bisogna mantenere una cache o strutturare il DB 
      // con subcollection di eventi. Per semplicità in questo microservizio, useremo
      // un trucco: cerchiamo di ricordare l'ultimo stato noto.

      const previousState = global.usersCache ? global.usersCache[userId] : null;
      
      // Aggiorniamo la cache
      if (!global.usersCache) global.usersCache = {};
      global.usersCache[userId] = receivedRequests;

      // Se non avevamo lo stato precedente, lo saltiamo per evitare falsi positivi all'avvio
      if (!previousState) return;

      // Se le richieste ricevute sono aumentate
      if (receivedRequests.length > previousState.length) {
        console.log(`🔔 Nuova richiesta di amicizia per l'utente ${userId}! Invio notifica...`);

        if (fcmTokens.length === 0) {
          console.log(`⚠️ Impossibile inviare notifica: Nessun token FCM registrato per ${userId}.`);
          return;
        }

        const message = {
          notification: {
            title: 'Nuova richiesta di amicizia',
            body: 'Qualcuno vuole stringere amicizia con te su Cesena Remembers!'
          },
          data: {
            type: 'friend_request'
          },
          tokens: fcmTokens // Invia a tutti i dispositivi registrati per questo utente
        };

        try {
          const response = await admin.messaging().sendEachForMulticast(message);
          console.log(`✅ Notifiche inviate a ${response.successCount} dispositivi.`);
          if (response.failureCount > 0) {
            console.log(`❌ Invio fallito per ${response.failureCount} dispositivi.`);
            // Potresti voler ripulire i token falliti dal DB
          }
        } catch (error) {
          console.error("Errore durante l'invio della notifica:", error);
        }
      }
    } else if (change.type === 'added') {
      // Memorizziamo lo stato iniziale per i documenti esistenti quando il server parte
      if (!global.usersCache) global.usersCache = {};
      global.usersCache[change.doc.id] = change.doc.data().receivedFriendRequests || [];
    }
  });
}, err => {
  console.error("Errore durante l'ascolto di Firestore:", err);
});
