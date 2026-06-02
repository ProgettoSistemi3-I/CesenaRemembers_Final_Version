import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Literal
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
    userXp: int
    languageCode: Literal["it", "en"] = "it"
# ------------------------

@app.post("/api/generate-quiz", response_model=QuizResponse)
async def generate_quiz(poi: PoiRequest):
    try:
        # 1. Calcolo del livello di difficoltà in base agli XP
        language_code = poi.languageCode if poi.languageCode in ("it", "en") else "it"
        language_name = "Italiano" if language_code == "it" else "English"
        sample_question = (
            "testo della domanda in italiano"
            if language_code == "it"
            else "question text in English"
        )
        sample_options = (
            ["opzione 1", "opzione 2", "opzione 3"]
            if language_code == "it"
            else ["option 1", "option 2", "option 3"]
        )

        xp = poi.userXp
        if language_code == "it":
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
        else:
            if xp <= 200:
                difficulty_level = "Level 1 (Easy)"
                difficulty_desc = "Questions about the main and best-known historical facts connected to the place during the war."
            elif xp <= 400:
                difficulty_level = "Level 2 (Medium)"
                difficulty_desc = "Less-known details, specific dates, or general tactical events from World War II in the local context."
            elif xp <= 600:
                difficulty_level = "Level 3 (Hard)"
                difficulty_desc = "Causes, complex consequences, minor key figures, and partisan or military dynamics specific to this place."
            else:
                difficulty_level = "Level 4 (Expert)"
                difficulty_desc = "Deep analysis, micro-anecdotes, historical documents, or extremely specific tactical details about World War II in Cesena."

        # 2. Prompt aggiornato con focus sulla WWII, blocco delle banalità, difficoltà e lingua scelta nell'app
        prompt = f"""
        Sei un esperto di storia locale della città di Cesena e un creatore di quiz storici di alto livello.
        Devi generare un quiz a risposta multipla su questo luogo storico:

        NOME LUOGO: {poi.name}
        DESCRIZIONE: {poi.description}
        LINGUA OBBLIGATORIA DEL QUIZ: {language_name} ({language_code})
        DIFFICOLTÀ RICHIESTA: {difficulty_level} - {difficulty_desc}

        Regole FONDAMENTALI:
        1. Genera esattamente 5 domande nella LINGUA OBBLIGATORIA indicata sopra.
        2. Anche tutte le opzioni di risposta devono essere nella LINGUA OBBLIGATORIA.
        3. TEMA CENTRALE: La stragrande maggioranza delle domande DEVE riguardare vicende, eventi o il contesto della Seconda Guerra Mondiale (WWII) legati a questo luogo.
        4. DIVIETO ASSOLUTO DI BANALITÀ: Non fare MAI domande scontate come "In che città si trova?", "Come si chiama questo luogo?" o dettagli visivi ovvi. Dai per scontato che l'utente sia già fisicamente lì.
        5. VARIETÀ DEI TEMI: Ogni domanda delle 5 richieste deve trattare un aspetto, un aneddoto o un dettaglio storico DIFFERENTE della Seconda Guerra Mondiale. Evita assolutamente di ripetere lo stesso concetto o lo stesso evento (es. rastrellamenti) in più domande.
        6. INTEGRAZIONE: Usa le informazioni della DESCRIZIONE, ma arricchiscile con la tua conoscenza storica accurata sulla Seconda Guerra Mondiale a Cesena per rispettare il livello di difficoltà richiesto.
        7. Ogni domanda deve avere tra 3 e 4 opzioni di risposta sensate. Non mettere opzioni palesemente false o ridicole.
        8. Indica l'indice corretto (partendo da 0). Randomizza la posizione della risposta corretta (non metterla sempre alla posizione 0).

        DEVI e puoi SOLO restituire un oggetto JSON valido con questa esatta struttura:
        {{
            "questions": [
                {{
                    "question": "{sample_question}",
                    "options": {json.dumps(sample_options, ensure_ascii=False)},
                    "correctIndex": 0
                }}
            ]
        }}
        """

        chat_completion = client.chat.completions.create(
            messages=[
                {
                    "role": "system",
                    "content": f"You are a JSON generator. Return ONLY valid JSON matching the requested schema. All human-readable quiz text must be in {language_name}."
                },
                {
                    "role": "user",
                    "content": prompt,
                }
            ],
            model="llama-3.3-70b-versatile",
            response_format={"type": "json_object"},
            temperature=0.2,
        )

        response_content = chat_completion.choices[0].message.content
        return json.loads(response_content)

    except Exception as e:
        print(f"Errore durante la generazione del quiz: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    return {"status": "Il server dei quiz di Cesena Remembers è online!"}