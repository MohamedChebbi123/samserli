from controller.housecontroller import add_houses,fetch_houses,fetch_user_properties,delete_user_property,modify_user_property
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
    rooms:int=Form(...),
    status:str=Form(...),
    price:float=Form(...),
    name :str=Form(...),
    description :str=Form(...),
    house_pictures:list[UploadFile]=File(...),
    db:session=Depends(connect_databse),
    authorization: str | None = Header(None)):
    
    return add_houses(latitude,longitude,rooms,status,price,name,description,house_pictures,db,authorization)


@router.get("/fetch_houses")
def fetch_houses_as_user(db:session=Depends(connect_databse),
                authorization: str | None = Header(None)):
    return fetch_houses(db,authorization)



@router.get("/fetch_user_properties")
def fetch_users_properties(db:session=Depends(connect_databse),
                authorization: str | None = Header(None)):
    return fetch_user_properties(db,authorization)


@router.delete("/delete_property/{house_id}")
def delete_property(house_id: int,
                    db: session = Depends(connect_databse),
                    authorization: str | None = Header(None)):
    return delete_user_property(house_id, db, authorization)


@router.put("/modify_property")
def modify_property(house_id: int = Form(...),
                    latitude: float = Form(None),
                    longitude: float = Form(None),
                    rooms: int = Form(None),
                    status: str = Form(None),
                    price: float = Form(None),
                    name: str = Form(None),
                    description: str = Form(None),
                    house_pictures: list[UploadFile] = File(None),
                    db: session = Depends(connect_databse),
                    authorization: str | None = Header(None)):
    return modify_user_property(house_id, latitude, longitude, rooms, status, price, name, description, house_pictures, db, authorization)