from fastapi import File, Form, Header, UploadFile,HTTPException,status,Depends
from models.Users import Users
from utils.cloudinary_handler import upload_user_profile_image
from utils.hasher import hash_password,verify_password
from sqlalchemy.orm import session
from database.connection import connect_databse
from schemas.Userlogin import Userlogin
from utils.jwt_handler import create_access_token,verify_access_token
from schemas.Messageschema import Messageschema
from models.Message import Message
from models.BlockedUsers import BlockedUsers
from models.PasswordReset import PasswordReset
from utils.emailsender import send_password_reset_code
import random
from datetime import datetime, timedelta

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

def send_message(
    sender_id: int,
    receiver_id: int,
    content: str,
    image: UploadFile | None,
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    authenticated_user_id = int(payload["sub"])
    
    if authenticated_user_id != sender_id:
        raise HTTPException(status_code=403, detail="Cannot send message as another user")
    
    receiver = db.query(Users).filter(Users.user_id == receiver_id).first()
    if not receiver:
        raise HTTPException(status_code=404, detail="Receiver not found")
    
    block_exists = db.query(BlockedUsers).filter(
        ((BlockedUsers.blocker_id == sender_id) & (BlockedUsers.blocked_id == receiver_id)) |
        ((BlockedUsers.blocker_id == receiver_id) & (BlockedUsers.blocked_id == sender_id))
    ).first()
    
    if block_exists:
        raise HTTPException(status_code=403, detail="Cannot send message to this user")
    
    image_url = None
    if image:
        from utils.cloudinary_handler import upload_message_image
        image_url = upload_message_image(image)
    
    new_message = Message(
        sender_id=sender_id,
        receiver_id=receiver_id,
        content=content,
        image_url=image_url
    )
    
    db.add(new_message)
    db.commit()
    db.refresh(new_message)
    
    return {
        "msg": "Message sent successfully",
        "message_id": new_message.id,
        "image_url": image_url
    }

def get_conversation(
    other_user_id: int,
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    current_user_id = int(payload["sub"])
    
    from models.Message import Message
    messages = db.query(Message).filter(
        ((Message.sender_id == current_user_id) & (Message.receiver_id == other_user_id)) |
        ((Message.sender_id == other_user_id) & (Message.receiver_id == current_user_id))
    ).order_by(Message.sent_at).all()
    
    return [
        {
            "id": msg.id,
            "sender_id": msg.sender_id,
            "receiver_id": msg.receiver_id,
            "content": msg.content,
            "image_url": msg.image_url,
            "sent_at": msg.sent_at.isoformat() if msg.sent_at else None,
            "is_mine": msg.sender_id == current_user_id
        }
        for msg in messages
    ]

def update_message(
    message_id: int,
    new_content: str,
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    current_user_id = int(payload["sub"])
    
    message = db.query(Message).filter(Message.id == message_id).first()
    
    if not message:
        raise HTTPException(status_code=404, detail="Message not found")
    
    if message.sender_id != current_user_id:
        raise HTTPException(
            status_code=403, 
            detail="You can only update your own messages"
        )
    
    message.content = new_content
    db.commit()
    db.refresh(message)
    
    return {
        "msg": "Message updated successfully",
        "message": {
            "id": message.id,
            "content": message.content,
            "sent_at": message.sent_at.isoformat() if message.sent_at else None
        }
    }

def delete_message(
    message_id: int,
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    current_user_id = int(payload["sub"])
    
    message = db.query(Message).filter(Message.id == message_id).first()
    
    if not message:
        raise HTTPException(status_code=404, detail="Message not found")
    
    if message.sender_id != current_user_id:
        raise HTTPException(
            status_code=403, 
            detail="You can only delete your own messages"
        )
    
    db.delete(message)
    db.commit()
    
    return {
        "msg": "Message deleted successfully"
    }

def get_all_conversations(
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    current_user_id = int(payload["sub"])
    
    from sqlalchemy import or_, case, func
    
    other_user_id_col = case(
        (Message.sender_id == current_user_id, Message.receiver_id),
        else_=Message.sender_id
    )
    
    subquery = (
        db.query(
            Message.id,
            Message.sender_id,
            Message.receiver_id,
            Message.content,
            Message.sent_at,
            other_user_id_col.label('other_user_id'),
            func.row_number()
            .over(
                partition_by=other_user_id_col,
                order_by=Message.sent_at.desc()
            )
            .label('rn')
        )
        .filter(
            or_(
                Message.sender_id == current_user_id,
                Message.receiver_id == current_user_id
            )
        )
        .subquery()
    )
    
    latest_messages = (
        db.query(subquery)
        .filter(subquery.c.rn == 1)
        .all()
    )
    
    conversations = []
    for msg in latest_messages:
        other_user = db.query(Users).filter(Users.user_id == msg.other_user_id).first()
        
        if other_user:
            unread_count = db.query(Message).filter(
                Message.sender_id == msg.other_user_id,
                Message.receiver_id == current_user_id,
                Message.is_read == False
            ).count()
            
            conversations.append({
                "user_id": other_user.user_id,
                "user_name": f"{other_user.first_name} {other_user.last_name}",
                "user_image": other_user.profile_picture or "",
                "last_message": msg.content,
                "last_message_time": msg.sent_at.isoformat() if msg.sent_at else None,
                "is_last_message_mine": msg.sender_id == current_user_id,
                "unread_count": unread_count
            })
    
    conversations.sort(key=lambda x: x['last_message_time'] or '', reverse=True)
    
    return conversations

def edit_profile(
    first_name: str = Form(None),
    last_name: str = Form(None),
    phone_number: str = Form(None),
    profile_picture: UploadFile = File(None),
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    user_id = payload["sub"]
    
    found_user = db.query(Users).filter(Users.user_id == user_id).first()
    
    if not found_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if first_name:
        if len(first_name.strip()) < 6:
            raise HTTPException(status_code=400, detail="First name should be more than 6 characters")
        found_user.first_name = first_name
    
    if last_name:
        if len(last_name.strip()) < 6:
            raise HTTPException(status_code=400, detail="Last name should be more than 6 characters")
        found_user.last_name = last_name
    
    if phone_number:
        if len(phone_number) < 8:
            raise HTTPException(status_code=400, detail="Phone number should be at least 8 characters")
        found_user.phone_number = phone_number
    
    if profile_picture and profile_picture.filename:
        profile_image_url = upload_user_profile_image(profile_picture)
        found_user.profile_picture = profile_image_url
    
    db.commit()
    db.refresh(found_user)
    
    return {
        "msg": "Profile updated successfully",
        "first_name": found_user.first_name,
        "last_name": found_user.last_name,
        "email": found_user.email,
        "profile_picture": found_user.profile_picture,
        "phone_number": found_user.phone_number
    }

def get_unread_message_count(
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    current_user_id = int(payload["sub"])
    
    unread_count = db.query(Message).filter(
        Message.receiver_id == current_user_id,
        Message.is_read == False
    ).count()
    
    return {"unread_count": unread_count}

def mark_conversation_as_read(
    other_user_id: int,
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    current_user_id = int(payload["sub"])
    
    db.query(Message).filter(
        Message.sender_id == other_user_id,
        Message.receiver_id == current_user_id,
        Message.is_read == False
    ).update({"is_read": True})
    
    db.commit()
    
    return {"msg": "Messages marked as read"}

def block_user(
    user_id_to_block: int,
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    current_user_id = int(payload["sub"])
    
    if current_user_id == user_id_to_block:
        raise HTTPException(status_code=400, detail="Cannot block yourself")
    
    user_to_block = db.query(Users).filter(Users.user_id == user_id_to_block).first()
    if not user_to_block:
        raise HTTPException(status_code=404, detail="User not found")
    
    existing_block = db.query(BlockedUsers).filter(
        BlockedUsers.blocker_id == current_user_id,
        BlockedUsers.blocked_id == user_id_to_block
    ).first()
    
    if existing_block:
        raise HTTPException(status_code=400, detail="User already blocked")
    
    new_block = BlockedUsers(
        blocker_id=current_user_id,
        blocked_id=user_id_to_block
    )
    
    db.add(new_block)
    db.commit()
    
    return {"msg": "User blocked successfully"}

def unblock_user(
    user_id_to_unblock: int,
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    current_user_id = int(payload["sub"])
    
    block = db.query(BlockedUsers).filter(
        BlockedUsers.blocker_id == current_user_id,
        BlockedUsers.blocked_id == user_id_to_unblock
    ).first()
    
    if not block:
        raise HTTPException(status_code=404, detail="User is not blocked")
    
    db.delete(block)
    db.commit()
    
    return {"msg": "User unblocked successfully"}

def check_block_status(
    other_user_id: int,
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    current_user_id = int(payload["sub"])
    
    i_blocked_them = db.query(BlockedUsers).filter(
        BlockedUsers.blocker_id == current_user_id,
        BlockedUsers.blocked_id == other_user_id
    ).first() is not None
    
    they_blocked_me = db.query(BlockedUsers).filter(
        BlockedUsers.blocker_id == other_user_id,
        BlockedUsers.blocked_id == current_user_id
    ).first() is not None
    
    return {
        "i_blocked_them": i_blocked_them,
        "they_blocked_me": they_blocked_me
    }

def get_blocked_users(
    authorization: str | None = Header(None),
    db: session = Depends(connect_databse)
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization.split(" ")[1]
    payload = verify_access_token(token)

    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    current_user_id = int(payload["sub"])
    
    blocked = db.query(BlockedUsers).filter(
        BlockedUsers.blocker_id == current_user_id
    ).all()
    
    blocked_users = []
    for block in blocked:
        user = db.query(Users).filter(Users.user_id == block.blocked_id).first()
        if user:
            blocked_users.append({
                "user_id": user.user_id,
                "user_name": f"{user.first_name} {user.last_name}",
                "user_image": user.profile_picture or "",
                "blocked_at": block.blocked_at.isoformat() if block.blocked_at else None
            })
    
    return blocked_users

async def request_password_reset(
    email: str = Form(...),
    db: session = Depends(connect_databse)
):
    user = db.query(Users).filter(Users.email == email).first()
    
    if not user:
        raise HTTPException(
            status_code=404, 
            detail="No account found with this email address"
        )
    
    verification_code = str(random.randint(1000, 9999))
    
    expires_at = datetime.utcnow() + timedelta(minutes=10)
    
    password_reset = PasswordReset(
        email=email,
        verification_code=verification_code,
        expires_at=expires_at,
        is_used=0
    )
    
    db.add(password_reset)
    db.commit()
    
    try:
        await send_password_reset_code(email, verification_code)
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to send email: {str(e)}"
        )
    
    return {
        "msg": "Verification code sent to your email",
        "email": email
    }

def verify_reset_code(
    email: str = Form(...),
    code: str = Form(...),
    db: session = Depends(connect_databse)
):
    reset_request = db.query(PasswordReset).filter(
        PasswordReset.email == email,
        PasswordReset.verification_code == code,
        PasswordReset.is_used == 0
    ).order_by(PasswordReset.created_at.desc()).first()
    
    if not reset_request:
        raise HTTPException(
            status_code=400,
            detail="Invalid verification code"
        )
    
    if datetime.utcnow() > reset_request.expires_at:
        raise HTTPException(
            status_code=400,
            detail="Verification code has expired. Please request a new one."
        )
    
    return {
        "msg": "Code verified successfully",
        "email": email,
        "code": code
    }

def reset_password(
    email: str = Form(...),
    code: str = Form(...),
    new_password: str = Form(...),
    db: session = Depends(connect_databse)
):
    reset_request = db.query(PasswordReset).filter(
        PasswordReset.email == email,
        PasswordReset.verification_code == code,
        PasswordReset.is_used == 0
    ).order_by(PasswordReset.created_at.desc()).first()
    
    if not reset_request:
        raise HTTPException(
            status_code=400,
            detail="Invalid verification code"
        )
    
    if datetime.utcnow() > reset_request.expires_at:
        raise HTTPException(
            status_code=400,
            detail="Verification code has expired"
        )
    
    user = db.query(Users).filter(Users.email == email).first()
    
    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )
    
    user.password = hash_password(new_password)
    
    reset_request.is_used = 1
    
    db.commit()
    
    return {
        "msg": "Password reset successfully"
    }