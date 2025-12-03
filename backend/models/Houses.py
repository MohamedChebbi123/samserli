from database.connection import Base
from sqlalchemy import Column, String, Integer, DECIMAL, Text, JSON,ForeignKey
from sqlalchemy.orm import relationship
class Houses(Base):
    __tablename__ = "houses"  

    house_id = Column(Integer, primary_key=True, index=True)
    latitude = Column(DECIMAL, nullable=False)
    longitude = Column(DECIMAL, nullable=False)
    rooms=Column(Integer,nullable=False)
    status=Column(String,nullable=False)
    price=Column(DECIMAL,nullable=False)
    name = Column(String, nullable=False)
    description = Column(Text, nullable=False) 
    house_pictures = Column(JSON) 
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)

    
    user = relationship("Users", back_populates="houses")