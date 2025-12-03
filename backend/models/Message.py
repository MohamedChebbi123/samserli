from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, Boolean, func
from sqlalchemy.orm import relationship
from database.connection import Base

class Message(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True, index=True)

    sender_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    receiver_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)

    content = Column(Text, nullable=False)
    image_url = Column(String, nullable=True)
    sent_at = Column(DateTime(timezone=True), server_default=func.now())
    is_read = Column(Boolean, default=False, nullable=False)

    sender = relationship("Users",foreign_keys=[sender_id],back_populates="sent_messages")
    receiver = relationship("Users",foreign_keys=[receiver_id],back_populates="received_messages")
