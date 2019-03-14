from flask import current_app, jsonify, request
from webargs import fields, ValidationError
from . import bp
from server.utils import is_email_valid, bad_request
from webargs.flaskparser import FlaskParser
from server.models.user import User, user_schema
from server import db
from flask_jwt_extended import create_access_token

'''
Helpers
'''


def email_validator(email: str):
    if not is_email_valid(email):
        raise ValidationError("Invalid email")


# noinspection PyUnresolvedReferences
auth_args = {
    "email": fields.Str(required=True, validate=email_validator),
    # Validation
    "password": fields.Str(required=True)
}


class AuthRequestException(Exception):
    def __init__(self, invalid_dict):
        self.invalid_dict = invalid_dict

    def get_message(self):
        for field in self.invalid_dict:
            return "{}: {}".format(field, self.invalid_dict[field][0])
        return ""

    @staticmethod
    def handle_error(err, req, schema, status_code, error_headers):
        raise AuthRequestException(err.messages)


auth_parser = FlaskParser(locations=("json",), error_handler=AuthRequestException.handle_error)


def create_token(user: User):
    return create_access_token(user.id, user_claims={"email": user.email})


'''
Login
'''


@bp.route("/login", methods=["POST"])
def login():
    err_message = "Invalid credentials"
    try:
        login_args = auth_parser.parse(auth_args, request)
        email = login_args["email"]
        user = User.query.filter_by(email=email).first()
        if not user:
            return bad_request(err_message, 400)
        if user.verify_password(login_args["password"]):
            return jsonify({
                "token": create_token(user)
            })
        else:
            return bad_request(err_message, 400)
    except AuthRequestException:
        return bad_request(err_message, 400)


'''
Signup
'''


@bp.route("/signup", methods=["POST"])
def signup():
    try:
        signup_args = auth_parser.parse(auth_args, request)
        email = signup_args["email"]
        if User.query.filter_by(email=email).first():
            return bad_request("Duplicate User", 400)
        user = User(email=email, password=signup_args["password"])
        db.session.add(user)
        db.session.commit()
        rd = user_schema.dump(user).data
        rd["token"] = create_token(user)
        return jsonify(rd), 201
    except AuthRequestException as e:
        return bad_request(e.get_message(), 400)


@bp.route("/env", methods=["GET"])
def env():
    return jsonify({
        "name": current_app.config["CONFIG_NAME"],
        "debug": current_app.config["DEBUG"]
    })
