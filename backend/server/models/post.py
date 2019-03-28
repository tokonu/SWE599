from server import db, ma
from server.utils import timestamp


class Post(db.Model):
    __tablename__ = "posts"
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(64), nullable=False)
    description = db.Column(db.Text)
    created_at = db.Column(db.Integer, default=timestamp)
    updated_at = db.Column(db.Integer, default=timestamp, onupdate=timestamp)
    creator_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    group_id = db.Column(db.Integer, db.ForeignKey('groups.id'))


class PostSchema(ma.ModelSchema):
    class Meta:
        model = Post
        fields = ("id", "name")


post_schema = PostSchema()
posts_schema = PostSchema(many=True)