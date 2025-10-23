from sqlalchemy import String,Column,Integer
from database.connection import Base

class Users(Base):
    __tablename__="users"
    
    user_id=Column(Integer,primary_key=True,index=True)
    first_name=Column(String,nullable=False)
    last_name=Column(String,nullable=False)
    email=Column(String,nullable=False,unique=True)
    password=Column(String,nullable=False)
    profile_picture=Column(String,nullable=False)
    phone_number=Column(String,nullable=False,unique=True)
