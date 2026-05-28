FROM node:18-alpine

# Imposta la directory di lavoro
WORKDIR /usr/src/app

# Copia i file per l'installazione delle dipendenze
COPY package*.json ./

# Installa le dipendenze
RUN npm install

# Copia il codice sorgente
COPY . .

# Comando per avviare il servizio
CMD [ "npm", "start" ]
