from sqlalchemy import Column, Integer, ForeignKey
from sqlalchemy.orm import relationship
from database.connection import Base

class Favourites(Base):
    __tablename__ = "favourites"

    favourite_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    house_id = Column(Integer, ForeignKey("houses.house_id"), nullable=False)

    # Relations
    user = relationship("Users", back_populates="favourites")
    house = relationship("Houses", back_populates="favourited_by")