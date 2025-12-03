from pydantic import BaseModel
from typing import Optional

class Messageschema(BaseModel):
    sender_id :int
    receiver_id :int
    content : str
    image_url : Optional[str] = None
   