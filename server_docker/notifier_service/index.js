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
    
    if (change.type === 'modified') {
      const newData = change.doc.data();
      
      // Estrarre dati necessari
      const receivedRequests = newData.receivedFriendRequests || [];
      const sentRequests = newData.sentFriendRequests || []; // 🔴 NUOVO: Tracciamo le inviate
      const friends = newData.friends || []; 
      const fcmTokens = newData.fcmTokens || [];
      const userId = change.doc.id;

      const previousState = global.usersCache ? global.usersCache[userId] : null;
      
      // Aggiorniamo la cache includendo anche i sentRequests
      if (!global.usersCache) global.usersCache = {};
      global.usersCache[userId] = {
        requestsCount: receivedRequests.length,
        friendsCount: friends.length,
        sentCount: sentRequests.length // 🔴 NUOVO
      };

      // Se non avevamo lo stato precedente, lo saltiamo per evitare falsi positivi all'avvio
      if (!previousState) return;

      // ------------------------------------------------------------------
      // CASO 1: NUOVA RICHIESTA RICEVUTA
      // ------------------------------------------------------------------
      if (receivedRequests.length > previousState.requestsCount) {
        console.log(`🔔 Nuova richiesta di amicizia per l'utente ${userId}!`);
        await inviaNotifica(fcmTokens, {
          title: 'Nuova richiesta di amicizia',
          body: 'Qualcuno vuole stringere amicizia con te su Cesena Remembers!',
          type: 'friend_request'
        });
      }

      // ------------------------------------------------------------------
      // CASO 2: RICHIESTA ACCETTATA (Nuovo amico aggiunto)
      // ------------------------------------------------------------------
      // 🔴 IL FIX: Inviamo la notifica SOLO a chi ha visto diminuire le sue richieste INVIATE
      if (friends.length > previousState.friendsCount && sentRequests.length < previousState.sentCount) {
        console.log(`🤝 L'utente ${userId} ha un nuovo amico (aveva inviato lui la richiesta)!`);
        await inviaNotifica(fcmTokens, {
          title: 'Nuova Amicizia!',
          body: 'La tua richiesta di amicizia è stata accettata.',
          type: 'friend_accepted'
        });
      }

    } else if (change.type === 'added') {
      // Inizializza la cache all'avvio del server per i documenti già esistenti
      if (!global.usersCache) global.usersCache = {};
      global.usersCache[change.doc.id] = {
        requestsCount: (change.doc.data().receivedFriendRequests || []).length,
        friendsCount: (change.doc.data().friends || []).length,
        sentCount: (change.doc.data().sentFriendRequests || []).length // 🔴 NUOVO
      };
    }
  });
}, err => {
  console.error("Errore durante l'ascolto di Firestore:", err);
});

// Funzione helper per inviare la notifica pulendo il codice principale
async function inviaNotifica(tokens, payload) {
  if (tokens.length === 0) {
    console.log(`⚠️ Impossibile inviare notifica: Nessun token FCM registrato.`);
    return;
  }

  const message = {
    notification: {
      title: payload.title,
      body: payload.body
    },
    data: {
      type: payload.type
    },
    tokens: tokens 
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(`✅ Notifica "${payload.title}" inviata a ${response.successCount} dispositivi.`);
  } catch (error) {
    console.error("Errore durante l'invio della notifica:", error);
  }
}