import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List
from groq import Groq
from dotenv import load_dotenv
import json

load_dotenv()

app = FastAPI(title="Cesena Remembers - Quiz API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

client = Groq()

# --- MODELLI PYDANTIC ---
class QuizQuestion(BaseModel):
    question: str = Field(description="La domanda del quiz sul POI")
    options: List[str] = Field(description="Esattamente 3 o 4 opzioni di risposta")
    correctIndex: int = Field(description="L'indice (da 0 in poi) dell'opzione corretta")

class QuizResponse(BaseModel):
    questions: List[QuizQuestion] = Field(description="Una lista di esattamente 5 domande")

class PoiRequest(BaseModel):
    id: str
    name: str
    description: str
    userXp: int  # <-- NUOVO CAMPO AGGIUNTO
# ------------------------

@app.post("/api/generate-quiz", response_model=QuizResponse)
async def generate_quiz(poi: PoiRequest):
    try:
        # 1. Calcolo del livello di difficoltà in base agli XP
        xp = poi.userXp
        if xp <= 200:
            difficulty_level = "Livello 1 (Facile)"
            difficulty_desc = "Domande sui fatti storici principali e più noti legati al luogo durante la guerra."
        elif xp <= 400:
            difficulty_level = "Livello 2 (Medio)"
            difficulty_desc = "Dettagli meno noti, date specifiche o eventi tattici generali della Seconda Guerra Mondiale nel contesto locale."
        elif xp <= 600:
            difficulty_level = "Livello 3 (Difficile)"
            difficulty_desc = "Cause, conseguenze complesse, figure chiave minori e dinamiche partigiane o militari specifiche di questo luogo."
        else:
            difficulty_level = "Livello 4 (Esperto)"
            difficulty_desc = "Analisi profonda, aneddoti microscopici, documenti storici o dettagli tattici estremamente specifici della Seconda Guerra Mondiale a Cesena."

        # 2. Prompt aggiornato con focus sulla WWII, blocco delle banalità e iniezione della difficoltà
        prompt = f"""
        Sei un esperto di storia locale della città di Cesena e un creatore di quiz storici di alto livello.
        Devi generare un quiz a risposta multipla su questo luogo storico:
        
        NOME LUOGO: {poi.name}
        DESCRIZIONE: {poi.description}
        DIFFICOLTÀ RICHIESTA: {difficulty_level} - {difficulty_desc}
        
        Regole FONDAMENTALI:
        1. Genera esattamente 5 domande in italiano.
        2. TEMA CENTRALE: La stragrande maggioranza delle domande DEVE riguardare vicende, eventi o il contesto della Seconda Guerra Mondiale (WWII) legati a questo luogo.
        3. DIVIETO ASSOLUTO DI BANALITÀ: Non fare MAI domande scontate come "In che città si trova?", "Come si chiama questo luogo?" o dettagli visivi ovvi. Dai per scontato che l'utente sia già fisicamente lì.
        4. INTEGRAZIONE: Usa le informazioni della DESCRIZIONE, ma arricchiscile con la tua conoscenza storica accurata sulla Seconda Guerra Mondiale a Cesena per rispettare il livello di difficoltà richiesto.
        5. Ogni domanda deve avere tra 3 e 4 opzioni di risposta sensate (sempre in italiano). Non mettere opzioni palesemente false o ridicole.
        6. Indica l'indice corretto (partendo da 0). Randomizza la posizione della risposta corretta (non metterla sempre alla posizione 0).
        
        DEVI e puoi SOLO restituire un oggetto JSON valido con questa esatta struttura:
        {{
            "questions": [
                {{
                    "question": "testo della domanda in italiano",
                    "options": ["opzione 1", "opzione 2", "opzione 3"],
                    "correctIndex": 0
                }}
            ]
        }}
        """

        chat_completion = client.chat.completions.create(
            messages=[
                {
                    "role": "system",
                    "content": "You are a JSON generator. You must return ONLY a valid JSON object matching the requested schema exactly."
                },
                {
                    "role": "user",
                    "content": prompt,
                }
            ],
            model="llama-3.1-8b-instant",
            response_format={"type": "json_object"},
            temperature=0.1, # Leggermente alzata per dare più creatività nella formulazione di domande difficili
        )

        response_content = chat_completion.choices[0].message.content
        return json.loads(response_content)

    except Exception as e:
        print(f"Errore durante la generazione del quiz: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    return {"status": "Il server dei quiz di Cesena Remembers è online!"}