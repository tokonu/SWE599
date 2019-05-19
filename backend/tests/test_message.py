from .base import BaseTestCase
from server.models.user import User
from server.models.post import Post
from server.models.message import Message
from server import db


class TestsMessage(BaseTestCase):

    def test_endpoint_auth(self):

        endpoints = [
            ("groups/1/posts/1/messages", "get"),
        ]

        self.endpoint_auth_tester(endpoints)

    def test_posts(self):
        # create user
        email = "a@b.com"
        token = self.get_token(email=email)
        # create groups
        r, s, h = self.create_group("g1", tags=None, token=token)

        # create post
        r, s, h = self.create_post(group_id=1, title="title", description="desc", token=token)

        user = User.query.filter_by(email=email).first()
        post = Post.query.get(1)

        m1 = Message(text="t1", post=post, creator_id=user.id)
        m2 = Message(text="t2", post=post, creator_id=user.id)
        m3 = Message(text="t3", post=post, creator_id=user.id)
        m4 = Message(text="t4", post=post, creator_id=user.id)

        db.session.add(m1)
        db.session.add(m2)
        db.session.add(m3)
        db.session.add(m4)
        db.session.commit()

        r, s, h = self.get("/groups/1/posts/1/messages", token=token)
        self.assertEqual(s, 200)
        self.assertEqual(len(r["messages"]), 4)
        self.assertEqual(r["post-id"], 1)
        for i in range(1, 4):
            self.assertTrue(r["messages"][i-1]["created-at"] <= r["messages"][i]["created-at"])
        self.assertDictEqual(r["messages"][0], {"id": 1, "text": "t1", "creator-id": 1,
                                                "post-id": 1, "created-at": r["messages"][0]["created-at"]})
