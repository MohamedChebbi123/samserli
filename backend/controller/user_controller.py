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
    data: Messageschema,
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

    sender_id = int(payload["sub"])
    
    # Verify sender matches the authenticated user
    if sender_id != data.sender_id:
        raise HTTPException(status_code=403, detail="Cannot send message as another user")
    
    # Verify receiver exists
    receiver = db.query(Users).filter(Users.user_id == data.receiver_id).first()
    if not receiver:
        raise HTTPException(status_code=404, detail="Receiver not found")
    
    # Create message

    new_message = Message(
        sender_id=data.sender_id,
        receiver_id=data.receiver_id,
        content=data.content
    )
    
    db.add(new_message)
    db.commit()
    db.refresh(new_message)
    
    return {
        "msg": "Message sent successfully",
        "message_id": new_message.id
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
    
    # Get all messages between the two users
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
    
    # Find the message
    message = db.query(Message).filter(Message.id == message_id).first()
    
    if not message:
        raise HTTPException(status_code=404, detail="Message not found")
    
    # Verify the user is the sender of the message
    if message.sender_id != current_user_id:
        raise HTTPException(
            status_code=403, 
            detail="You can only update your own messages"
        )
    
    # Update the message content
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
    
    # Find the message
    message = db.query(Message).filter(Message.id == message_id).first()
    
    if not message:
        raise HTTPException(status_code=404, detail="Message not found")
    
    # Verify the user is the sender of the message
    if message.sender_id != current_user_id:
        raise HTTPException(
            status_code=403, 
            detail="You can only delete your own messages"
        )
    
    # Delete the message
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
    
    # Get all unique users the current user has conversed with
    from sqlalchemy import or_, case, func
    
    # Create a computed column for the "other user" in the conversation
    other_user_id_col = case(
        (Message.sender_id == current_user_id, Message.receiver_id),
        else_=Message.sender_id
    )
    
    # Subquery to get the latest message for each conversation
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
    
    # Get only the latest message for each conversation
    latest_messages = (
        db.query(subquery)
        .filter(subquery.c.rn == 1)
        .all()
    )
    
    conversations = []
    for msg in latest_messages:
        # Get the other user's info
        other_user = db.query(Users).filter(Users.user_id == msg.other_user_id).first()
        
        if other_user:
            conversations.append({
                "user_id": other_user.user_id,
                "user_name": f"{other_user.first_name} {other_user.last_name}",
                "user_image": other_user.profile_picture or "",
                "last_message": msg.content,
                "last_message_time": msg.sent_at.isoformat() if msg.sent_at else None,
                "is_last_message_mine": msg.sender_id == current_user_id
            })
    
    # Sort by most recent message
    conversations.sort(key=lambda x: x['last_message_time'] or '', reverse=True)
    
    return conversations