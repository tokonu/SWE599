import os

basedir = os.path.abspath(os.path.dirname(__file__))


class Config(object):
    CONFIG_NAME = "Base"
    DEBUG = False
    TESTING = False
    SECRET_KEY = "default-secret"
    JWT_SECRET_KEY = "more-secret"
    SQLALCHEMY_DATABASE_URI = os.environ.get(
        'DATABASE_URL', 'sqlite:///' + os.path.join(basedir, 'db.sqlite'))
    SQLALCHEMY_TRACK_MODIFICATIONS = False


class DevelopmentConfig(Config):
    CONFIG_NAME = "Development"
    DEBUG = True


class ProductionConfig(Config):
    CONFIG_NAME = "Production"
    SECRET_KEY = os.environ.get('SECRET_KEY', Config.SECRET_KEY)
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY', Config.SECRET_KEY)
    pass


class TestingConfig(Config):
    CONFIG_NAME = "Testing"
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(basedir, 'test.sqlite')


config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig
}