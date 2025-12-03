from controller.user_controller import register,login,view_profile,send_message,get_conversation,update_message,delete_message,get_all_conversations,edit_profile,get_unread_message_count,mark_conversation_as_read,block_user,unblock_user,check_block_status,get_blocked_users,request_password_reset,verify_reset_code,reset_password
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
    sender_id: int = Form(...),
    receiver_id: int = Form(...),
    content: str = Form(...),
    image: UploadFile = File(None),
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    return send_message(sender_id, receiver_id, content, image, authorization, db)


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


@router.get("/get_unread_message_count")
def get_unread_count(
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    return get_unread_message_count(authorization, db)


@router.put("/mark_conversation_as_read/{other_user_id}")
def mark_as_read(
    other_user_id: int,
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    return mark_conversation_as_read(other_user_id, authorization, db)


@router.post("/block_user/{user_id_to_block}")
def block_user_route(
    user_id_to_block: int,
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    return block_user(user_id_to_block, authorization, db)


@router.delete("/unblock_user/{user_id_to_unblock}")
def unblock_user_route(
    user_id_to_unblock: int,
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    return unblock_user(user_id_to_unblock, authorization, db)


@router.get("/check_block_status/{other_user_id}")
def check_block_status_route(
    other_user_id: int,
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    return check_block_status(other_user_id, authorization, db)


@router.get("/get_blocked_users")
def get_blocked_users_route(
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    return get_blocked_users(authorization, db)


@router.post("/request_password_reset")
async def request_password_reset_route(
    email: str = Form(...),
    db: session = Depends(connect_databse)
):
    return await request_password_reset(email, db)


@router.post("/verify_reset_code")
def verify_reset_code_route(
    email: str = Form(...),
    code: str = Form(...),
    db: session = Depends(connect_databse)
):
    return verify_reset_code(email, code, db)


@router.post("/reset_password")
def reset_password_route(
    email: str = Form(...),
    code: str = Form(...),
    new_password: str = Form(...),
    db: session = Depends(connect_databse)
):
    return reset_password(email, code, new_password, db)