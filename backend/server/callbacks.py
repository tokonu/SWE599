from flask_jwt_extended import JWTManager
from server.models.user import User
from server.utils import bad_request


def register_jwt_callbacks(manager: JWTManager):
    manager.user_loader_callback_loader(jwt_user_loader)
    manager.unauthorized_loader(jwt_unauthorized)
    manager.invalid_token_loader(jwt_invalid_token)
    manager.expired_token_loader(jwt_expired_token)


def jwt_user_loader(identity: int):
    return User.query.get(identity)


def jwt_unauthorized(_):
    return bad_request("unauthorized", 401)


def jwt_invalid_token(_):
    return bad_request("invalid_token", 401)


def jwt_expired_token(_):
    return bad_request("expired_token", 401)

