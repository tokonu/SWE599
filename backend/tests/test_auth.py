from .base import BaseTestCase
from server.models.user import User, user_schema


class TestsAuth(BaseTestCase):
    def test_endpoint_methods(self):
        r, s, h = self.get('auth/login')
        self.assertEqual(s, 405)

        r, s, h = self.get('auth/signup')
        self.assertEqual(s, 405)

        r, s, h = self.post('auth/me')
        self.assertEqual(s, 405)

    def test_email_validation(self):
        from server.utils import is_email_valid
        valid_emails = ["f@b.co",
                        "foo@bar.net",
                        "f11@b11.com"]
        invalid_emails = ["@bar.com",
                          "f@bar",
                          "foo @bar.com",
                          "foobar.com"]
        for email in valid_emails:
            self.assertTrue(is_email_valid(email))
        for email in invalid_emails:
            self.assertFalse(is_email_valid(email))

    def test_signup(self):

        # incomplete request
        r, s, h = self.signup_user("a@b.com")
        self.assertEqual(s, 400)
        self.assertTrue("message" in r)

        # invalid email
        r, s, h = self.signup_user("ab.com", "aaa")
        self.assertEqual(s, 400)
        self.assertTrue("message" in r)

        # create user
        r, s, h = self.signup_user("a@b.com", "foo")
        self.assertEqual(s, 201)
        self.assertTrue("token" in r)
        self.assertEqual(r["email"], "a@b.com")
        self.assertEqual(r["id"], 1)
        self.assertTrue("password" not in r)

        user = User.query.filter_by(email="a@b.com").first()
        self.assertIsNotNone(user)
        self.assertNotEqual(user.password_hash, "foo")
        try:
            user.password
        except AttributeError:
            pass
        else:
            self.fail("User password did not raise AttributeError")
        self.assertTrue(user.verify_password("foo"))
        self.assertDictEqual(user_schema.dump(user).data, {"id": 1, "email": "a@b.com"})

        # create duplicate user
        r, s, h = self.signup_user("a@b.com", "aaa")
        self.assertEqual(s, 400)
        self.assertEqual(r["message"], "Duplicate User")

    def test_login(self):

        # non existing user
        r, s, h = self.login_user("a@b.com", "aaa")
        self.assertEqual(s, 400)
        self.assertEqual(r["message"], "Invalid credentials")

        # create user
        self.signup_user("a@b.com", "aaa")

        # login user
        r, s, h = self.login_user("a@b.com", "aaa")
        self.assertEqual(s, 200)
        self.assertTrue("token" in r)

        # login with incorrect password
        r, s, h = self.login_user("a@b.com", "aaa1")
        self.assertEqual(s, 400)
        self.assertEqual(r["message"], "Invalid credentials")

    def test_me(self):
        email = "a@b.com"
        token = self.get_token(email=email)

        r, s, h = self.get("/auth/me", token=token)
        self.assertDictEqual(r, {"id": 1, "email": "a@b.com", "groups": []})

        # create groups
        r, s, h = self.create_group(name="foo", tags=None, token=token)
        r, s, h = self.create_group(name="bar", tags=["baz"], token=token)

        r, s, h = self.get("/auth/me", token=token)
        self.assertEqual(s, 200)
        self.assertEqual(r["id"], 1)
        self.assertEqual(r["email"], "a@b.com")
        self.assertEqual(len(r["groups"]), 2)
        for group in r["groups"]:
            if group["name"] == "foo":
                self.assertDictEqual(group, {"id": 1, "name": "foo", "tags": []})
            if group["name"] == "bar":
                self.assertDictEqual(group, {"id": 2, "name": "bar", "tags": ["baz"]})

    # todo test admin route auth
