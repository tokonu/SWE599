from flask import Flask
import os

from flask_jwt_extended import JWTManager

from config import config
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow

db = SQLAlchemy()
ma = Marshmallow()

import server.models


def create_app(config_name=None):
    if config_name is None:
        config_name = os.environ.get('FLASK_CONFIG', 'development')

    app = Flask(__name__)
    # app.config.from_object('config.{}'.format(config_name.capitalize()))
    app.config.from_object(config[config_name])

    db.init_app(app)
    ma.init_app(app)
    JWTManager(app)

    from .blueprints.auth import bp as auth_bp
    app.register_blueprint(auth_bp, url_prefix="/auth")

    return app
