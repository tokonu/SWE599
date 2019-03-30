from marshmallow import fields

from server import db, ma
from server.utils import timestamp


class Post(db.Model):
    __tablename__ = "posts"
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(64), nullable=False)
    description = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.Integer, default=timestamp)
    updated_at = db.Column(db.Integer, default=timestamp, onupdate=timestamp)
    creator_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    group_id = db.Column(db.Integer, db.ForeignKey('groups.id'), nullable=False)

    def as_dict(self):
        d = post_schema.dump(self).data
        if self.creator.username:
            d["creator-username"] = self.creator.username
        return d


class PostSchema(ma.ModelSchema):
    class Meta:
        model = Post
        fields = ("id", "title", "description", "created_at", "group_id")
    created_at = fields.Number(dump_to="created-at")
    group_id = fields.Number(dump_to="group-id")

post_schema = PostSchema()
posts_schema = PostSchema(many=True)
