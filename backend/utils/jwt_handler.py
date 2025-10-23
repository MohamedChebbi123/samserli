from datetime import datetime, timedelta, timezone
from jose import JWTError, jwt


SECRET_KEY = "P1C#.G!%hSR<Yv%qy0c;R~pqZ[7(<KhS4;Tx0~+.c:$&!)8*qL/.?fMH7~cx" # i know
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 180

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_access_token(token: str):
    try:
        payload = jwt.decode(str(token), SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError as e :
        print (e)
        return None
    