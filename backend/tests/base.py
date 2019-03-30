from unittest import TestCase
import json
from server import create_app, db
from datetime import timedelta
import time


# noinspection PyBroadException
class BaseTestCase(TestCase):

    def setUp(self):
        self.app = create_app()
        self.ctx = self.app.app_context()
        self.ctx.push()
        self.client = self.app.test_client()
        db.drop_all()
        db.create_all()

    def tearDown(self):
        db.drop_all() # has to be before pop context
        # print(inspect(db.engine).bind)
        self.ctx.pop()

    def test_config_is_testing(self):
        self.assertTrue(self.app.config["TESTING"])

    def get_headers(self, token):
        headers = {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        }
        if token is not None:
            headers['Authorization'] = 'Bearer ' + token
        return headers

    def get(self, url, token=None):
        rv = self.client.get(url, headers=self.get_headers(token))
        # clean up the database session, since this only occurs when the app
        # context is popped.
        db.session.remove()
        body = rv.get_data(as_text=True)
        if body is not None and body != '':
            try:
                body = json.loads(body)
            except:
                pass
        return body, rv.status_code, rv.headers

    def post(self, url, data=None, token=None):
        d = data if data is None else json.dumps(data)
        rv = self.client.post(url, data=d, headers=self.get_headers(token))
        # clean up the database session, since this only occurs when the app
        # context is popped.
        db.session.remove()
        body = rv.get_data(as_text=True)
        if body is not None and body != '':
            try:
                body = json.loads(body)
            except:
                pass
        return body, rv.status_code, rv.headers

    def signup_user(self, email=None, password=None):
        return self.post('/auth/signup', {'email': email, "password": password})

    def login_user(self, email=None, password=None):
        return self.post('/auth/login', {'email': email, "password": password})

    def get_token(self, email="a@b.com", password="foo"):
        r, s, h = self.signup_user(email, password)
        return r["token"]

    def endpoint_auth_tester(self, endpoints):
        self.app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(milliseconds=200)
        token = self.get_token(email="a@b.com")

        for url, method in endpoints:
            func = self.get if method == "get" else self.post
            # no token
            r, s, h = func(url=url, token=None)
            self.assertEqual(s, 401, msg=url)
            self.assertEqual(r["message"], "unauthorized", msg=url)
            # incorrect token
            r, s, h = func(url=url, token="foo")
            self.assertEqual(s, 401, msg=url)
            self.assertEqual(r["message"], "invalid_token", msg=url)

        # method not allowed
        for url, method in endpoints:
            func = self.get if method == "post" else self.post
            # no token
            r, s, h = func(url=url, token=None)
            self.assertEqual(s, 405, msg=url)

        time.sleep(1.5)
        # expired token
        for url, method in endpoints:
            func = self.get if method == "get" else self.post

            r, s, h = func(url=url, token=token)
            self.assertEqual(s, 401, msg=url)
            self.assertEqual(r["message"], "expired_token", msg=url)
