from controller.housecontroller import add_houses,fetch_houses
from fastapi import APIRouter
from models.Houses import Houses
from fastapi import File, Form, Header, UploadFile,HTTPException,status,Depends
from models.Users import Users
from utils.cloudinary_handler import upload_user_profile_image
from utils.hasher import hash_password,verify_password
from sqlalchemy.orm import session
from database.connection import connect_databse
from schemas.Userlogin import Userlogin
from utils.jwt_handler import create_access_token,verify_access_token
router=APIRouter()

@router.post("/add_house")
def add_your_house(latitude:float=Form(...),
    longitude:float=Form(...),
    status:str=Form(...),
    price:float=Form(...),
    name :str=Form(...),
    description :str=Form(...),
    house_pictures:list[UploadFile]=File(...),
    db:session=Depends(connect_databse),
    authorization: str | None = Header(None)):
    
    return add_houses(latitude,longitude,status,price,name,description,house_pictures,db,authorization)


@router.get("/fetch_houses")
def fetch_houses_as_user(db:session=Depends(connect_databse),
                authorization: str | None = Header(None)):
    return fetch_houses(db,authorization)