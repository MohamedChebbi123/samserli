from pydantic import BaseModel

class Userlogin(BaseModel):
    email:str
    password:str
    