from fastapi import File, Form, UploadFile,HTTPException,status,Depends
from models.Users import Users
from utils.cloudinary_handler import upload_user_profile_image
from utils.hasher import hash_password
from sqlalchemy.orm import session
from database.connection import connect_databse

def register(
    first_name:str=Form(...),
    last_name:str=Form(...),
    email:str=Form(...),
    password:str=Form(...),
    profile_picture:UploadFile=File(...),
    phone_number:str=Form(...),
    db:session=Depends(connect_databse)):
    
    if len(first_name.strip())<6 and len(last_name.strip())<6:
        raise HTTPException(status.HTTP_400_BAD_REQUEST,detail="user name and lastname should be more than 6 cxharatcerts")
    
    if len(phone_number)<8:
        raise HTTPException(status.HTTP_400_BAD_REQUEST,detail="phonen umber should be 8 characters") 
    
    if '@' not in email or '.' not in email:
        raise HTTPException(status_code=400, detail="Enter a valid email")
    
    profile_image_url=upload_user_profile_image(profile_picture)
    password_hashed=hash_password(password)
    
    
    new_user=Users(
        first_name=first_name,
        last_name=last_name,
        email=email,
        password=password_hashed,
        profile_picture=profile_image_url,
        phone_number=phone_number
    )
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return {
        "msg":"user added succesully",
        'userid':f"{new_user.first_name}"
    }