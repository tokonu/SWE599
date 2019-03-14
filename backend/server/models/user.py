from server import db, ma
from server.utils import timestamp
from werkzeug.security import generate_password_hash, check_password_hash


class User(db.Model):
    __tablename__ = "users"
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(64), nullable=False, unique=True)
    password_hash = db.Column(db.String(256), nullable=False)
    created_at = db.Column(db.Integer, default=timestamp)
    updated_at = db.Column(db.Integer, default=timestamp, onupdate=timestamp)

    @property
    def password(self):
        raise AttributeError('password is not a readable attribute')

    @password.setter
    def password(self, password):
        self.password_hash = generate_password_hash(password)

    def verify_password(self, psw):
        return check_password_hash(self.password_hash, psw)


class UserSchema(ma.ModelSchema):
    class Meta:
        model = User
        fields = ("id", "email")


user_schema = UserSchema()
