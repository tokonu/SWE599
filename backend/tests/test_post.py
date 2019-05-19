from server.models.post import Post
from .base import BaseTestCase
import time
from server.models.user import User


class TestsPost(BaseTestCase):

    def test_endpoint_auth(self):

        endpoints = [
            ("groups/1/posts", "get"),
            ("groups/1/posts/create", "post")
        ]

        self.endpoint_auth_tester(endpoints)

    def test_posts(self):
        # create user
        email = "a@b.com"
        token = self.get_token(email=email)
        # create groups
        r, s, h = self.create_group("g1", tags=None, token=token)
        g1_id = r["id"]
        r, s, h = self.create_group("g2", tags=None, token=token)
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
        self.assertEqual(r["creator-id"], 1)
        self.assertEqual(r["group-id"], g1_id)
        self.assertAlmostEqual(r["created-at"], time.time(), delta=1)

        # create more posts
        self.create_post(group_id=g1_id, title="title", description="desc", token=token)
        self.create_post(group_id=g1_id, title="title", description="desc", token=token)
        self.create_post(group_id=g1_id, title="title", description="desc", token=token)
        self.create_post(group_id=g2_id, title="title", description="desc", token=token)
        self.create_post(group_id=g2_id, title="title", description="desc", token=token)

        user = User.query.filter_by(email=email).first()
        self.assertEqual(len(user.posts_created.all()), 6)
        posts = Post.query.all()
        for post in posts:
            self.assertEqual(post.creator.id, user.id)

        # get posts
        r, s, h = self.get(url=f"/groups/{g1_id}/posts", token=token)
        self.assertEqual(s, 200)
        self.assertEqual(r["group-id"], g1_id)
        self.assertEqual(len(r["posts"]), 4)
        # posts are sorted by create time
        posts = r["posts"]
        for i in range(len(posts)-1):
            self.assertTrue(posts[i]["created-at"] >= posts[i+1]["created-at"])

        # get posts
        r, s, h = self.get(url=f"/groups/{g2_id}/posts", token=token)
        self.assertEqual(s, 200)
        self.assertEqual(r["group-id"], g2_id)
        self.assertEqual(len(r["posts"]), 2)
