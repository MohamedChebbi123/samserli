from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from models import Users
from models import Houses
from models import Message
from database.connection import engine, Base
from routes import userroute
from routes import houseroute
app=FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(userroute.router)
app.include_router(houseroute.router)

Base.metadata.create_all(bind=engine)
