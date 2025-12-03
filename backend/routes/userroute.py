from controller.user_controller import register,login,view_profile,send_message,get_conversation,update_message,delete_message,get_all_conversations,edit_profile
from schemas.Messageschema import Messageschema
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


@router.post("/send_message")
def send_user_message(
    data: Messageschema,
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    return send_message(data, authorization, db)


@router.get("/get_conversation/{other_user_id}")
def get_user_conversation(
    other_user_id: int,
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    return get_conversation(other_user_id, authorization, db)


@router.put("/update_message/{message_id}")
def update_user_message(
    message_id: int,
    new_content: str = Form(...),
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    return update_message(message_id, new_content, authorization, db)


@router.delete("/delete_message/{message_id}")
def delete_user_message(
    message_id: int,
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    return delete_message(message_id, authorization, db)


@router.get("/get_all_conversations")
def get_conversations(
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    return get_all_conversations(authorization, db)


@router.put("/edit_profile")
def update_profile(
    first_name: str = Form(None),
    last_name: str = Form(None),
    phone_number: str = Form(None),
    profile_picture: UploadFile = File(None),
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    return edit_profile(first_name, last_name, phone_number, profile_picture, authorization, db)