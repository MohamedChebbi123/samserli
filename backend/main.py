from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from models import Users
from database.connection import engine, Base
from routes import userroute

app=FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(userroute.router)

Base.metadata.create_all(bind=engine)
