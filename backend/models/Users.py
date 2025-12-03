from sqlalchemy import Column, String, Integer
from sqlalchemy.orm import relationship
from database.connection import Base

class Users(Base):
    __tablename__ = "users"
    
    user_id = Column(Integer, primary_key=True, index=True)
    first_name = Column(String, nullable=False)
    last_name = Column(String, nullable=False)
    email = Column(String, nullable=False, unique=True)
    password = Column(String, nullable=False)
    profile_picture = Column(String, nullable=False)
    phone_number = Column(String, nullable=False, unique=True)

    houses = relationship("Houses", back_populates="user")

    # 🔵 Messages envoyés
    sent_messages = relationship(
        "Message",
        foreign_keys="Message.sender_id",
        back_populates="sender"
    )

    # 🔴 Messages reçus
    received_messages = relationship(
        "Message",
        foreign_keys="Message.receiver_id",
        back_populates="receiver"
    )
