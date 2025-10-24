from controller.user_controller import register,login,view_profile
from fastapi import APIRouter, Depends, File, Header, UploadFile,Form
from sqlalchemy.orm import session
from database.connection import connect_databse
from schemas.Userlogin import Userlogin

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
    
@router.post("/login_user")
def login_user(data:Userlogin,db:session=Depends(connect_databse)):
    return login(data,db)


@router.get("/get_profile")
def user_profile(authorization: str | None = Header(None),db:session=Depends(connect_databse)):
    return view_profile(authorization,db)