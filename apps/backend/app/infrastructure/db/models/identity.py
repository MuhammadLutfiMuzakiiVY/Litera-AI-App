from uuid import UUID

from sqlalchemy import Boolean, ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.infrastructure.db.base import Base, TimestampMixin, UuidPrimaryKeyMixin


class User(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "users"

    email: Mapped[str] = mapped_column(String(320), unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    role: Mapped[str] = mapped_column(String(32), index=True)
    full_name: Mapped[str | None] = mapped_column(String(160))
    email_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    profile_completed: Mapped[bool] = mapped_column(Boolean, default=False)

    student_profile: Mapped["StudentProfile | None"] = relationship(
        back_populates="user",
    )
    teacher_profile: Mapped["TeacherProfile | None"] = relationship(
        back_populates="user",
    )


class School(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "schools"

    name: Mapped[str] = mapped_column(String(180), index=True)
    city: Mapped[str | None] = mapped_column(String(120))
    province: Mapped[str | None] = mapped_column(String(120))


class StudentProfile(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "student_profiles"

    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id"), unique=True)
    school_id: Mapped[UUID | None] = mapped_column(ForeignKey("schools.id"))
    grade_level: Mapped[str] = mapped_column(String(32))
    learning_preference: Mapped[str | None] = mapped_column(String(32))

    user: Mapped[User] = relationship(back_populates="student_profile")
    school: Mapped[School | None] = relationship()


class TeacherProfile(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "teacher_profiles"

    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id"), unique=True)
    school_id: Mapped[UUID | None] = mapped_column(ForeignKey("schools.id"))
    subject_area: Mapped[str] = mapped_column(String(64))

    user: Mapped[User] = relationship(back_populates="teacher_profile")
    school: Mapped[School | None] = relationship()


class Classroom(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "classrooms"

    school_id: Mapped[UUID | None] = mapped_column(ForeignKey("schools.id"))
    name: Mapped[str] = mapped_column(String(120))
    academic_year: Mapped[str] = mapped_column(String(16))
    created_by: Mapped[UUID | None] = mapped_column(ForeignKey("users.id"))


class ClassroomMember(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "classroom_members"
    __table_args__ = (
        UniqueConstraint("classroom_id", "user_id", name="uq_classroom_user"),
    )

    classroom_id: Mapped[UUID] = mapped_column(ForeignKey("classrooms.id"))
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id"))
    member_role: Mapped[str] = mapped_column(String(32))

