from models.Houses import Houses
from fastapi import File, Form, Header, UploadFile,HTTPException,status,Depends
from models.Users import Users
from models.Houses import Houses
from models.Favourites import Favourites
from utils.cloudinary_handler import upload_user_profile_image
from utils.hasher import hash_password,verify_password
from sqlalchemy.orm import session
from database.connection import connect_databse
from schemas.Userlogin import Userlogin
from utils.jwt_handler import create_access_token,verify_access_token
from sqlalchemy.orm import joinedload

def add_houses( 
    latitude:float=Form(...),
    longitude:float=Form(...),
    rooms:int=Form(...),
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
        rooms=rooms,
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
    
def fetch_user_properties(db:session=Depends(connect_databse),
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
    
   found_houses=db.query(Houses).filter(Houses.user_id == userid).all()
    
   return[
       {   
           "id":found_house.house_id,
           "latitude":found_house.latitude,
           "longitude":found_house.longitude,
           "status":found_house.status,
           "price":found_house.price,
           "name":found_house.name,
           "rooms":found_house.rooms,
           "description":found_house.description,
           "house_picture":found_house.house_pictures
       }
       for found_house in found_houses
   ]
    
    
    
def fetch_houses(
    db: session = Depends(connect_databse),
    authorization: str | None = Header(None)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    userid = int(payload["sub"])

    found_houses = db.query(Houses).options(joinedload(Houses.user)).filter(Houses.user_id != userid).all()

    user_favourites = db.query(Favourites.house_id).filter(Favourites.user_id == userid).all()
    favourite_house_ids = {fav.house_id for fav in user_favourites}

    return [
        {
            "id": h.house_id,
            "latitude": h.latitude,
            "longitude": h.longitude,
            "rooms": h.rooms,
            "status": h.status,
            "price": h.price,
            "name": h.name,
            "description": h.description,
            "house_picture": h.house_pictures,
            "is_favourite": h.house_id in favourite_house_ids,
            "owner": {
                "user_id":h.user.user_id,
                "full_name": f"{h.user.first_name} {h.user.last_name}",
                "email": h.user.email,
                "phone_number": h.user.phone_number,
                "profile_picture": h.user.profile_picture
            }
        }
        for h in found_houses
    ]

def delete_user_property(
    house_id: int,
    db: session = Depends(connect_databse),
    authorization: str | None = Header(None)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    userid = payload["sub"]

    found_house = db.query(Houses).filter(
        Houses.house_id == house_id,
        Houses.user_id == userid
    ).first()

    if not found_house:
        raise HTTPException(
            status_code=404,
            detail="Property not found or you don't have permission to delete it"
        )

    db.delete(found_house)
    db.commit()

    return {
        "msg": "Property deleted successfully"
    }

def modify_user_property(
    house_id: int = Form(...),
    latitude: float = Form(None),
    longitude: float = Form(None),
    rooms: int = Form(None),
    status: str = Form(None),
    price: float = Form(None),
    name: str = Form(None),
    description: str = Form(None),
    house_pictures: list[UploadFile] = File(None),
    db: session = Depends(connect_databse),
    authorization: str | None = Header(None)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    userid = payload["sub"]

    found_house = db.query(Houses).filter(
        Houses.house_id == house_id,
        Houses.user_id == userid
    ).first()

    if not found_house:
        raise HTTPException(
            status_code=404,
            detail="Property not found or you don't have permission to modify it"
        )


    if latitude is not None:
        found_house.latitude = latitude
    if longitude is not None:
        found_house.longitude = longitude
    if rooms is not None:
        found_house.rooms = rooms
    if status is not None:
        found_house.status = status
    if price is not None:
        found_house.price = price
    if name is not None:
        found_house.name = name
    if description is not None:
        found_house.description = description

    if house_pictures:
        house_images_urls = []
        for picture in house_pictures:
            image_url = upload_user_profile_image(picture)
            house_images_urls.append(image_url)
        found_house.house_pictures = house_images_urls

    db.commit()
    db.refresh(found_house)

    return {
        "msg": "Property updated successfully",
        "property": {
            "id": found_house.house_id,
            "latitude": found_house.latitude,
            "longitude": found_house.longitude,
            "rooms": found_house.rooms,
            "status": found_house.status,
            "price": found_house.price,
            "name": found_house.name,
            "description": found_house.description,
            "house_picture": found_house.house_pictures
        }
    }

def add_to_favourites(
    house_id: int,
    db: session = Depends(connect_databse),
    authorization: str | None = Header(None)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    user_id = int(payload["sub"])

    house = db.query(Houses).filter(Houses.house_id == house_id).first()
    if not house:
        raise HTTPException(status_code=404, detail="House not found")

    existing_favourite = db.query(Favourites).filter(
        Favourites.user_id == user_id,
        Favourites.house_id == house_id
    ).first()

    if existing_favourite:
        raise HTTPException(status_code=400, detail="House is already in favourites")

    new_favourite = Favourites(
        user_id=user_id,
        house_id=house_id
    )

    db.add(new_favourite)
    db.commit()
    db.refresh(new_favourite)

    return {
        "msg": "House added to favourites successfully",
        "favourite_id": new_favourite.favourite_id
    }

def remove_from_favourites(
    house_id: int,
    db: session = Depends(connect_databse),
    authorization: str | None = Header(None)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    user_id = int(payload["sub"])

    favourite = db.query(Favourites).filter(
        Favourites.user_id == user_id,
        Favourites.house_id == house_id
    ).first()

    if not favourite:
        raise HTTPException(status_code=404, detail="House not found in favourites")

    db.delete(favourite)
    db.commit()

    return {
        "msg": "House removed from favourites successfully"
    }

def get_user_favourites(
    db: session = Depends(connect_databse),
    authorization: str | None = Header(None)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    user_id = int(payload["sub"])

    favourites = db.query(Favourites).options(
        joinedload(Favourites.house).joinedload(Houses.user)
    ).filter(Favourites.user_id == user_id).all()

    return [
        {
            "favourite_id": fav.favourite_id,
            "house": {
                "id": fav.house.house_id,
                "latitude": fav.house.latitude,
                "longitude": fav.house.longitude,
                "rooms": fav.house.rooms,
                "status": fav.house.status,
                "price": fav.house.price,
                "name": fav.house.name,
                "description": fav.house.description,
                "house_picture": fav.house.house_pictures,
                "owner": {
                    "user_id": fav.house.user.user_id,
                    "full_name": f"{fav.house.user.first_name} {fav.house.user.last_name}",
                    "email": fav.house.user.email,
                    "phone_number": fav.house.user.phone_number,
                    "profile_picture": fav.house.user.profile_picture
                }
            }
        }
        for fav in favourites
    ]

def check_if_favourite(
    house_id: int,
    db: session = Depends(connect_databse),
    authorization: str | None = Header(None)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    user_id = int(payload["sub"])

    favourite = db.query(Favourites).filter(
        Favourites.user_id == user_id,
        Favourites.house_id == house_id
    ).first()

    return {
        "is_favourite": favourite is not None,
        "favourite_id": favourite.favourite_id if favourite else None
    }