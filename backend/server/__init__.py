from flask import Flask
import os
from flask_jwt_extended import JWTManager
from config import config
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from flask_admin import Admin

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
    admin = Admin(app=app)
    jwt = JWTManager(app)

    from server.callbacks import register_jwt_callbacks
    register_jwt_callbacks(jwt)

    from .blueprints.admin import user_model_view
    admin.add_view(user_model_view)

    from .blueprints.auth import bp as auth_bp
    app.register_blueprint(auth_bp, url_prefix="/auth")

    from .blueprints.group import bp as groups_bp
    app.register_blueprint(groups_bp, url_prefix="/groups")

    return app
