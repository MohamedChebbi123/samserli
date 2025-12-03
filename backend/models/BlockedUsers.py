from sqlalchemy import Column, Integer, DateTime, ForeignKey, func, UniqueConstraint
from sqlalchemy.orm import relationship
from database.connection import Base

class BlockedUsers(Base):
    __tablename__ = "blocked_users"

    id = Column(Integer, primary_key=True, index=True)

    blocker_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    blocked_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)

    blocked_at = Column(DateTime(timezone=True), server_default=func.now())

    blocker = relationship("Users", foreign_keys=[blocker_id])
    blocked = relationship("Users", foreign_keys=[blocked_id])

    __table_args__ = (
        UniqueConstraint('blocker_id', 'blocked_id', name='unique_block'),
    )
