from uuid import UUID

from pydantic import BaseModel, Field


class UserSchema(BaseModel):
    id: UUID
    email: str
    role: str
    full_name: str | None = None
    email_verified: bool
    profile_completed: bool


class RegisterRequest(BaseModel):
    email: str
    password: str = Field(min_length=10)
    role: str = Field(pattern="^(student|teacher|admin)$")
    full_name: str | None = None


class LoginRequest(BaseModel):
    email: str
    password: str
    role: str = Field(default="student", pattern="^(student|teacher|admin)$")


class VerifyEmailRequest(BaseModel):
    otp: str = Field(min_length=6, max_length=6)


class RefreshTokenRequest(BaseModel):
    refresh_token: str


class AuthBootstrapResponse(BaseModel):
    user: UserSchema
    requires_email_verification: bool = True


class AuthTokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    expires_in: int
    user: UserSchema


class UserEnvelope(BaseModel):
    user: UserSchema

