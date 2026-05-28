# Usa un'immagine ufficiale di Python leggera come base
FROM python:3.11-slim

# Imposta la cartella di lavoro all'interno del container
WORKDIR /app

# Copia il file dei requisiti prima del resto del codice
# Questo sfrutta la cache di Docker: se non cambi i requisiti, 
# non reinstallerà tutto ogni volta che cambi il codice Python.
COPY requirements.txt .

# Installa le dipendenze
RUN pip install --no-cache-dir -r requirements.txt

# Copia tutto il resto del codice nella cartella di lavoro
COPY . .

# Esponi la porta su cui gira FastAPI
EXPOSE 8000

# Comando per avviare il server quando il container parte
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]