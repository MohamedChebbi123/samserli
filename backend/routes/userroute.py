from controller.user_controller import register
from fastapi import APIRouter, Depends, File, UploadFile,Form
from sqlalchemy.orm import session
from database.connection import connect_databse


router=APIRouter()

@router.post("/register_new_user")
def register_new_user(first_name:str=Form(...),
    last_name:str=Form(...),
    email:str=Form(...),
    password:str=Form(...),
    profile_picture:UploadFile=File(...),
    phone_number:str=Form(...),
    db:session=Depends(connect_databse)):
    
    return register(first_name,
    last_name,
    email,
    password,
    profile_picture,
    phone_number,
    db)