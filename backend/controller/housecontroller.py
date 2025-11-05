from models.Houses import Houses
from fastapi import File, Form, Header, UploadFile,HTTPException,status,Depends
from models.Users import Users
from models.Houses import Houses
from utils.cloudinary_handler import upload_user_profile_image
from utils.hasher import hash_password,verify_password
from sqlalchemy.orm import session
from database.connection import connect_databse
from schemas.Userlogin import Userlogin
from utils.jwt_handler import create_access_token,verify_access_token

def add_houses( 
    latitude:float=Form(...),
    longitude:float=Form(...),
    status:str=Form(...),
    price:float=Form(...),
    name :str=Form(...),
    description :str=Form(...),
    house_pictures:list[UploadFile]=File(...),
    db:session=Depends(connect_databse),
    authorization: str | None = Header(None)):
    
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    userid = payload["sub"]
    
    house_images_urls = []
    for picture in house_pictures:
        image_url = upload_user_profile_image(picture) 
        house_images_urls.append(image_url)
    
    new_house=Houses(
        latitude=latitude,
        longitude=longitude,
        status=status,
        price=price,
        name=name,
        description=description,
        house_pictures=house_images_urls,
        user_id=userid
        
    )
    db.add(new_house)
    db.commit()
    db.refresh(new_house)
    
    return{
        "msg":"house inseted succesfully"
    }
    
def fetch_houses(db:session=Depends(connect_databse),
                authorization: str | None = Header(None)):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    userid = payload["sub"]
    
    found_houses=db.query(Houses).all()
    
    return[
        {   
            "id":found_house.house_id,
            "latitude":found_house.latitude,
            "longitude":found_house.longitude,
            "status":found_house.status,
            "price":found_house.price,
            "name":found_house.name,
            "description":found_house.description,
            "house_picture":found_house.house_pictures
        }
        for found_house in found_houses
    ]
    
    
    
    