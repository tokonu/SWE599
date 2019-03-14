from .base import BaseTestCase
from server.models.user import User, user_schema


class TestsAuth(BaseTestCase):
    def test_endpoint_methods(self):
        r, s, h = self.get('auth/login')
        self.assertEqual(s, 405)

        r, s, h = self.get('auth/signup')
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

