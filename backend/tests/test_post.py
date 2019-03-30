from server.models.post import Post
from .base import BaseTestCase
import time
from server import db
from server.models.user import User
from server.models.group import Group


class TestsPost(BaseTestCase):

    def test_endpoint_auth(self):

        endpoints = [
            ("groups/1/posts", "get"),
            ("groups/1/posts/create", "post")
        ]

        self.endpoint_auth_tester(endpoints)

    def create_group(self, name, tags=None, token=None):
        data = {"name": name}
        if tags:
            data["tags"] = tags
        return self.post("groups/create", data=data, token=token)

    def create_post(self, group_id, title, description, token=None):
        data = {
            "title": title,
            "description": description
        }
        return self.post(f"groups/{group_id}/posts/create", data=data, token=token)

    def test_posts(self):
        # create user
        email = "a@b.com"
        token = self.get_token(email=email)
        # create groups
        r, s, h = self.create_group("g1", token=token)
        g1_id = r["id"]
        r, s, h = self.create_group("g2", token=token)
        g2_id = r["id"]

        # invalid request
        r, s, h = self.create_post(group_id=g1_id, title=1, description="desc", token=token)
        self.assertEqual(s, 400)
        self.assertTrue("message" in r)

        # no title
        r, s, h = self.create_post(group_id=g1_id, title=None, description="desc", token=token)
        self.assertEqual(s, 400)
        self.assertTrue("message" in r)

        # no description
        r, s, h = self.create_post(group_id=g1_id, title="title", description=None, token=token)
        self.assertEqual(s, 400)
        self.assertTrue("message" in r)

        # non existing group
        r, s, h = self.create_post(group_id=100, title="title", description="desc", token=token)
        self.assertEqual(s, 404)

        # create post
        r, s, h = self.create_post(group_id=g1_id, title="title", description="desc", token=token)
        self.assertEqual(s, 201)
        self.assertEqual(r["id"], 1)
        self.assertEqual(r["title"], "title")
        self.assertEqual(r["description"], "desc")
        self.assertTrue("creator-username" not in r)
        self.assertEqual(r["group-id"], g1_id)
        self.assertAlmostEqual(r["created-at"], time.time(), delta=1)

        user = User.query.filter_by(email=email).first()
        user.username = "user 1"
        db.session.commit()

        # create with user that has username
        r, s, h = self.create_post(group_id=g1_id, title="title", description="desc", token=token)
        self.assertEqual(s, 201)
        self.assertEqual(r["creator-username"], "user 1")

        # create more posts
        self.create_post(group_id=g1_id, title="title", description="desc", token=token)
        self.create_post(group_id=g1_id, title="title", description="desc", token=token)
        self.create_post(group_id=g1_id, title="title", description="desc", token=token)
        self.create_post(group_id=g2_id, title="title", description="desc", token=token)
        self.create_post(group_id=g2_id, title="title", description="desc", token=token)

        user = User.query.filter_by(email=email).first()
        self.assertEqual(len(user.posts_created.all()), 7)
        posts = Post.query.all()
        for post in posts:
            self.assertEqual(post.creator.id, user.id)

        # get posts
        r, s, h = self.get(url=f"/groups/{g1_id}/posts", token=token)
        self.assertEqual(s, 200)
        self.assertEqual(r["group-id"], g1_id)
        self.assertEqual(len(r["posts"]), 5)
        # posts are sorted by create time
        posts = r["posts"]
        for i in range(len(posts)-1):
            self.assertTrue(posts[i]["created-at"] >= posts[i+1]["created-at"])

        # get posts
        r, s, h = self.get(url=f"/groups/{g2_id}/posts", token=token)
        self.assertEqual(s, 200)
        self.assertEqual(r["group-id"], g2_id)
        self.assertEqual(len(r["posts"]), 2)
