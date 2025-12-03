from pydantic import BaseModel

class Messageschema(BaseModel):
    sender_id :int
    receiver_id :int
    content : str
   