from unittest import TestCase

from server import create_app


class TestsConfig(TestCase):
    def test_app_is_development(self):
        app = create_app("development")
        self.assertTrue(app.config["DEBUG"] is True)
        self.assertTrue(app.config["CONFIG_NAME"] is "Development")
        self.assertTrue(app.config["SECRET_KEY"] == "default-secret")

    def test_app_is_production(self):
        app = create_app("production")
        self.assertTrue(app.config["DEBUG"] is False)
        self.assertTrue(app.config["CONFIG_NAME"] is "Production")
        # todo run this for production
        # self.assertTrue(app.config["SECRET_KEY"] != "default-secret")
        # self.assertTrue(app.config["JWT_SECRET_KEY"] != "default-secret")

    def test_app_is_test(self):
        app = create_app()
        self.assertTrue(app.config["TESTING"] is True)
        self.assertTrue(app.config["CONFIG_NAME"] is "Testing")
