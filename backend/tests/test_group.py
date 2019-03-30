from .base import BaseTestCase
from server.models.user import User
from server.models.group import Group


class TestsGroup(BaseTestCase):

    def test_endpoint_auth(self):

        endpoints = [
            ("groups/create", "post"),
            ("groups/search", "get"),
            ("groups/1/join", "post"),
            ("groups/1/leave", "post")
        ]

        self.endpoint_auth_tester(endpoints)

    def create_group(self, name, tags, token=None):
        data = {"name": name}
        if tags:
            data["tags"] = tags
        return self.post("groups/create", data=data, token=token)

    def test_create_group(self):
        email = "a@b.com"
        token = self.get_token(email=email)

        # incomplete request
        r, s, h = self.create_group(name=None, tags=None, token=token)
        self.assertEqual(s, 400)
        self.assertTrue("message" in r)

        # create group
        r, s, h = self.create_group(name="foo", tags=None, token=token)
        self.assertEqual(s, 201)
        self.assertTrue("id" in r)
        self.assertTrue("name" in r)
        self.assertTrue("tags" in r)
        self.assertDictEqual(r, {"name": "foo", "id": 1, "tags": []})

        group = Group.query.filter_by(name="foo").first()
        user = User.query.filter_by(email=email).first()

        self.assertEqual(group.creator_id, user.id)
        self.assertEqual(group.creator.id, user.id)
        self.assertEqual(user.groups_created.first().id, group.id)
        self.assertEqual(user.groups.first().id, group.id)

        # create group with duplicate name
        r, s, h = self.create_group(name="foo", tags=None, token=token)
        self.assertEqual(s, 400)
        self.assertEqual(r["message"], "Duplicate group name")

        # create group with tags
        r, s, h = self.create_group(name="foo2", tags=["foo", "bar", "baz"], token=token)
        self.assertEqual(s, 201)
        self.assertEqual(r, {"name": "foo2", "id": 2, "tags": ["foo", "bar", "baz"]})

        # create group with different tags
        r, s, h = self.create_group(name="foo3", tags=["foo", "bar", 'tag'], token=token)
        self.assertEqual(s, 201)
        self.assertEqual(r, {"name": "foo3", "id": 3, "tags": ["foo", "bar", 'tag']})

    def test_search_group(self):
        # create user and groups
        token = self.get_token(email="a@b.com")
        r, s, h = self.create_group(name="foo", tags=["bar"], token=token)
        self.assertEqual(s, 201)
        r, s, h = self.create_group(name="foo 2", tags=["baz", "tag"], token=token)
        self.assertEqual(s, 201)

        # search with name
        r, s, h = self.get("/groups/search?q=foo", token=token)
        self.assertEqual(s, 200)
        self.assertEqual(r["query"], "foo")
        self.assertEqual(len(r["groups"]), 2)

        # search with incomplete name
        r, s, h = self.get("/groups/search?q=oo", token=token)
        self.assertEqual(s, 200)
        self.assertEqual(r["query"], "oo")
        self.assertEqual(len(r["groups"]), 2)

        # search with tag
        r, s, h = self.get("/groups/search?q=bar", token=token)
        self.assertEqual(s, 200)
        self.assertEqual(r["query"], "bar")
        self.assertEqual(len(r["groups"]), 1)
        self.assertEqual(r["groups"][0]["name"], "foo")

        # search with incomplete tag
        r, s, h = self.get("/groups/search?q=ba", token=token)
        self.assertEqual(s, 200)
        self.assertEqual(len(r["groups"]), 2)

        # search with incomplete tag
        r, s, h = self.get("/groups/search?q=ag", token=token)
        self.assertEqual(s, 200)
        self.assertEqual(len(r["groups"]), 1)

        # search with non existing name
        r, s, h = self.get("/groups/search?q=non", token=token)
        self.assertEqual(s, 200)
        self.assertEqual(len(r["groups"]), 0)

        # create another group
        r, s, h = self.create_group(name="bar", tags=["foo", "moo"], token=token)
        self.assertEqual(s, 201)

        r, s, h = self.get("/groups/search?q=ba", token=token)
        self.assertEqual(s, 200)
        self.assertEqual(len(r["groups"]), 3)

    def test_join_leave(self):
        # create user and groups
        token = self.get_token(email="a@b.com")
        self.create_group(name="foo", tags=["bar"], token=token)
        self.create_group(name="foo 2", tags=[], token=token)

        # create second user
        token = self.get_token(email="c@d.com")
        user = User.query.filter_by(email="c@d.com").first()
        self.assertEqual(len(user.groups.all()), 0)

        group_1 = Group.query.filter_by(name="foo").first()
        self.assertEqual(len(group_1.users.all()), 1)  # user that created the group is included
        group_2 = Group.query.filter_by(name="foo 2").first()
        self.assertEqual(len(group_2.users.all()), 1)

        g1_id = group_1.id
        g2_id = group_2.id

        # join groups
        r, s, h = self.post("/groups/{}/join".format(g1_id), token=token)
        self.assertEqual(s, 200)
        r, s, h = self.post("/groups/{}/join".format(g2_id), token=token)
        self.assertEqual(s, 200)
        # try to join again
        r, s, h = self.post("/groups/{}/join".format(g1_id), token=token)
        self.assertEqual(s, 200)

        group_1 = Group.query.filter_by(name="foo").first()
        group_2 = Group.query.filter_by(name="foo 2").first()
        user = User.query.filter_by(email="c@d.com").first()

        self.assertEqual(len(user.groups.all()), 2)
        self.assertEqual(len(group_1.users.all()), 2)
        self.assertEqual(len(group_2.users.all()), 2)

        # leave group
        r, s, h = self.post("/groups/{}/leave".format(g1_id), token=token)
        self.assertEqual(s, 200)
        # try to leave again
        r, s, h = self.post("/groups/{}/leave".format(g1_id), token=token)
        self.assertEqual(s, 200)

        group_1 = Group.query.filter_by(name="foo").first()
        group_2 = Group.query.filter_by(name="foo 2").first()
        user = User.query.filter_by(email="c@d.com").first()

        self.assertEqual(len(user.groups.all()), 1)
        self.assertEqual(user.groups.first().id, group_2.id)
        self.assertEqual(len(group_1.users.all()), 1)
        self.assertEqual(len(group_2.users.all()), 2)

