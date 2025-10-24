from fastapi import File, Form, Header, UploadFile,HTTPException,status,Depends
from models.Users import Users
from utils.cloudinary_handler import upload_user_profile_image
from utils.hasher import hash_password,verify_password
from sqlalchemy.orm import session
from database.connection import connect_databse
from schemas.Userlogin import Userlogin
from utils.jwt_handler import create_access_token,verify_access_token

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
    
    
def login(data:Userlogin,db:session=Depends(connect_databse)):
    
    found_user=db.query(Users).filter(Users.email==data.email).first()
    
    if not found_user:
        raise HTTPException(status.HTTP_404_NOT_FOUND ,detail="email not found")
    
    if not verify_password(data.password,found_user.password):
        raise HTTPException(status.HTTP_400_BAD_REQUEST,detail="wrong password")
    
    token=create_access_token({"sub": str(found_user.user_id)})
    
    
    return{"msg":"user logged in succesfully",
           "token":f"{token}",
           "user-cred":f"{found_user.user_id}"
           }
    
def view_profile(authorization: str | None = Header(None),db:session=Depends(connect_databse)):
    
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    userid = payload["sub"]
    
    found_user=db.query(Users).filter(Users.user_id==userid).first()
    
    return{"msg":"user profile returned succesfully",
           "first_name":found_user.first_name,
           "last_name": found_user.last_name,  
           "email":found_user.email,
           "profile_picture":found_user.profile_picture,
           "phone_number":found_user.phone_number,
           }