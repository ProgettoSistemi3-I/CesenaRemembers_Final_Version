from pydantic import BaseModel, Field
from typing import List, Literal

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
